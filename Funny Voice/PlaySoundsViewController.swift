//
//  PlaySoundsViewController.swift
//  Funny Voice
//
//  Created by Faisal Manzer on 22/04/18.
//  Copyright © 2018 Faisal Manzer. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController {
    
    @IBOutlet weak var btnSnail: UIButton!
    @IBOutlet weak var btnChipmunk: UIButton!
    @IBOutlet weak var btnRabbit: UIButton!
    @IBOutlet weak var btnVader: UIButton!
    @IBOutlet weak var btnEcho: UIButton!
    @IBOutlet weak var btnReverb: UIButton!
    @IBOutlet weak var btnStop: UIButton!
    
    var recorAudioURL:URL!
    var audioAVFile:AVAudioFile!
    var audioAVEngine:AVAudioEngine!
    var audioPlAVNode: AVAudioPlayerNode!
    var stopperTimer: Timer!
    
    enum ButtonType: Int {
        case slowVoice = 0, fastVoice = 1, chipmunkVoice = 2, vaderVoice = 3, echoVoice = 4, reverbVoice = 5
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAudio()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureUI(.notPlaying)
    }
    
    @IBAction func playSoundForButton(_ sender: UIButton) {
        print("Play Sound Button Pressed")
        switch(ButtonType(rawValue: sender.tag)!) {
        case .slowVoice:
            playSound(rate: 0.5)
        case .fastVoice:
            playSound(rate: 1.5)
        case .chipmunkVoice:
            playSound(pitch: 1000)
        case .vaderVoice:
            playSound(pitch: -1000)
        case .echoVoice:
            playSound(echo: true)
        case .reverbVoice:
            playSound(reverb: true)
        }
        
        configureUI(.playing)
    }
    
    @IBAction func stopButtonPressed(_ sender: AnyObject) {
        print("Stop Audio Button Pressed")
        stopAudio()
    }
    @IBAction func dismissViewcontroller(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
