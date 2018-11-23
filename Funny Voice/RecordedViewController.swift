//
//  RecordedViewController.swift
//  Funny Voice
//
//  Created by Faisal Manzer on 19/04/18.
//  Copyright © 2018 Faisal Manzer. All rights reserved.
//

import UIKit
import AVFoundation

class RecordedViewController: UIViewController, AVAudioRecorderDelegate {
    
    var audioRecorder: AVAudioRecorder!
    
    @IBOutlet weak var btnRecord: UIButton!
    @IBOutlet weak var lbRecord: UILabel!
    @IBOutlet weak var btnStop: UIButton!
    
    var nowRecording = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("View will Appear")
        btnStop.isEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("View Appeared")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func onClickRecordButton(_ sender: Any) {
        print("clicked record btn")
        lbRecord.text = "Recording..."
        btnRecord.isEnabled = false
        btnStop.isEnabled = true
        
        let diratePath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
        let recorName = "recordedVoice.wav"
        let pathArr = [diratePath, recorName]
        let filePth = URL(string: pathArr.joined(separator: "/"))
        
        print(filePth ?? "none")
        
        let sessionAV = AVAudioSession.sharedInstance()
        try! sessionAV.setCategory(AVAudioSessionCategoryPlayAndRecord, with:AVAudioSessionCategoryOptions.defaultToSpeaker)
        
        try! audioRecorder = AVAudioRecorder(url: filePth!, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    
    @IBAction func stopBtn(_ sender: Any) {
        print("Stop btn pressed")
        lbRecord.text = "Tap to record"
        btnRecord.isEnabled = true
        btnStop.isEnabled = false
        
        audioRecorder.stop()
        let audSession = AVAudioSession.sharedInstance()
        try! audSession.setActive(false)
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("Finish recording")
        if flag {
            print("Saved")
            performSegue(withIdentifier: "stopBtn", sender: audioRecorder.url)
        } else{
            print("Saving Failed")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stopBtn" {
            let playSoundVC = segue.destination as! PlaySoundsViewController
            let recordedAudioURL = sender as! URL
            playSoundVC.recorAudioURL = recordedAudioURL
        }
    }
    
}

