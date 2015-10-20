//
//  PlaySoundsViewController.swift
//  PitchPerfect
//
//  Created by Yevhen Herasymenko on 18/10/2015.
//  Copyright © 2015 YevhenHerasymenko. All rights reserved.
//

import UIKit
import AVFoundation


// For Echo and Reverb functions 
//I used tips and code from http://sandmemory.blogspot.com/2014/12/how-would-you-add-reverbecho-to-audio.html

class PlaySoundsViewController: UIViewController {
    
    var audioPlayer:AVAudioPlayer!
    var audioPlayerEcho:AVAudioPlayer!
    var receivedAudio: RecordedAudio!
    var audioEngine: AVAudioEngine!
    var audioFile:AVAudioFile!

    //MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        audioPlayer = try? AVAudioPlayer(contentsOfURL: receivedAudio.filePathUrl)
        audioPlayer.enableRate = true
        audioEngine = AVAudioEngine()
        audioFile = try? AVAudioFile(forReading: receivedAudio.filePathUrl)
        
        let session = AVAudioSession.sharedInstance()
        
        do {
            try session.overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker)
        } catch _ {
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Actions
    
    @IBAction func playSlowly(sender: UIButton) {
        audioPlayer.stop()
        audioPlayer.rate = 0.5
        audioPlayer.currentTime = 0.0
        audioPlayer.play()
    }
    
    @IBAction func playFaster(sender: UIButton) {
        audioPlayer.stop()
        audioPlayer.rate = 2.0
        audioPlayer.currentTime = 0.0
        audioPlayer.play()
    }
    
    @IBAction func playChipmunkAudio(sender: UIButton) {
        playAudioWithPitchVariable(1000)
    }
    
    @IBAction func playDarthVaderAudio(sender: UIButton) {
        playAudioWithPitchVariable(-1000)
    }
    
    @IBAction func playEchoAudio(sender: UIButton) {
        audioPlayer.stop()
        audioPlayer.currentTime = 0;
        audioPlayer.play()
        if audioPlayerEcho == nil {
           audioPlayerEcho = try? AVAudioPlayer(contentsOfURL: receivedAudio.filePathUrl)
        }
        if audioPlayerEcho != nil  {
            let delay:NSTimeInterval = 0.5
            let playtime:NSTimeInterval = audioPlayerEcho.deviceCurrentTime + delay
            audioPlayerEcho.stop()
            audioPlayerEcho.currentTime = 0
            audioPlayerEcho.volume = 0.6;
            audioPlayerEcho.playAtTime(playtime)
        } else {
            print ("Error!")
        }

    }
    
    @IBAction func playReverbAudio(sender: UIButton) {
        let N:Int = 10
        var reverbPlayers:[AVAudioPlayer] = []
        for _ in 0...N {
            if let audioPlayerTemp = try? AVAudioPlayer(contentsOfURL: receivedAudio.filePathUrl) {
                reverbPlayers.append(audioPlayerTemp)
            }
        }
        let delay:NSTimeInterval = 0.02
        for i in 0...N {
            let curDelay:NSTimeInterval = delay*NSTimeInterval(i)
            let player:AVAudioPlayer = reverbPlayers[i]
            let exponent:Double = -Double(i)/Double(N/2)
            let volume = Float(pow(Double(M_E), exponent))
            player.volume = volume
            player.playAtTime(player.deviceCurrentTime + curDelay)
        }
    }
    
    @IBAction func stop(sender: UIButton) {
        audioPlayer.stop()
    }
    
    func playAudioWithPitchVariable(pitch: Float) {
        audioPlayer.stop()
        audioEngine.stop()
        audioEngine.reset()
        
        let audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attachNode(audioPlayerNode)
        
        let changePitchEffect = AVAudioUnitTimePitch()
        changePitchEffect.pitch = pitch
        audioEngine.attachNode(changePitchEffect)
        
        audioEngine.connect(audioPlayerNode, to: changePitchEffect, format: nil)
        audioEngine.connect(changePitchEffect, to: audioEngine.outputNode, format: nil)
        
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        do {
            try audioEngine.start()
        } catch _ {
        }
        audioPlayerNode.play()
    }


}
