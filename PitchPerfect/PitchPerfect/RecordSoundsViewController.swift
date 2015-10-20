//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by Yevhen Herasymenko on 18/10/2015.
//  Copyright © 2015 YevhenHerasymenko. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    
    @IBOutlet weak var recordingInProgress: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var resumeButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    
    var audioRecorder:AVAudioRecorder!
    var recordedAudio:RecordedAudio!
    
    //MARK: - View Controller Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        stopButton.hidden = true
        recordButton.enabled = true
        resumeButton.hidden = true
        pauseButton.hidden = true
        
        recordingInProgress.text = "Tap to Record"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Actions
    
    @IBAction func recordAudio(sender: UIButton) {
        stopButton.hidden = false
        recordButton.enabled = false
        resumeButton.hidden = false
        pauseButton.hidden = false
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        
        let recordingName = "my_audio.wav"
        let pathArray = [dirPath, recordingName]
        let filePathUrl = NSURL.fileURLWithPathComponents(pathArray)
        
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        
        try! audioRecorder = AVAudioRecorder(URL: filePathUrl!, settings: Dictionary())
        audioRecorder.delegate = self
        audioRecorder.meteringEnabled = true
        audioRecorder.prepareToRecord()
        recordingState()
        
    }
    
    @IBAction func stopRecordAudio(sender: UIButton) {
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
    }
    
    @IBAction func pauseRecording(sender: UIButton) {
        pauseState()
    }
    
    @IBAction func resumeRecording(sender: UIButton) {
        recordingState()
    }
    
    //MARK: - AVAudioRecorderDelegate
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        if (flag) {
            recordedAudio = RecordedAudio(filePathUrl: recorder.url, title: recorder.url.lastPathComponent!)
            self.performSegueWithIdentifier("stopRecording", sender: recordedAudio)
        } else {
            print("Recording was not successful", terminator: "")
            recordButton.enabled = true
            stopButton.hidden = true
        }
        
    }
    
    //MARK: - Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "stopRecording") {
            let playSoundsVC: PlaySoundsViewController = segue.destinationViewController as! PlaySoundsViewController
            let data = sender as! RecordedAudio
            playSoundsVC.receivedAudio = data
        }
    }
    
    //Record Label State
    
    func recordingState() {
        recordingInProgress.text = "Recording in process"
        pauseButton.enabled = true
        resumeButton.enabled = false
        audioRecorder.record()
    }
    
    func pauseState() {
        recordingInProgress.text = "Recording was paused"
        pauseButton.enabled = false
        resumeButton.enabled = true
        audioRecorder.pause()
    }


}

