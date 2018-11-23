//
//  PlaySoundsViewController+Audio.swift
//  PitchPerfect
//
//  Copyright Â© 2016 Udacity. All rights reserved.
//

import UIKit
import AVFoundation

// MARK: - PlaySoundsViewController: AVAudioPlayerDelegate

extension PlaySoundsViewController: AVAudioPlayerDelegate {

    // MARK: Alerts

    struct AlertViews {
        static let DmissAlert = "Dismiss"
        static let RecorderDisabledTitle = "Recording Disabled"
        static let RecorderDisabledMessage = "You've disabled this app from recording your microphone. Check Settings."
        static let RecorderFailedTitle = "Recording Failed"
        static let RecorderFailedMessage = "Something went wrong with your recording."
        static let AudioRecordError = "Audio Recorder Error"
        static let AudioSessError = "Audio Session Error"
        static let AudioRecorderError = "Audio Recording Error"
        static let AudioAVFileError = "Audio File Error"
        static let AudioEnginerError = "Audio Engine Error"
    }

    // MARK: PlayingState (raw values correspond to sender tags)

    enum PlayingState { case playing, notPlaying }

    // MARK: Audio Functions

    func setupAudio() {
        // initialize (recording) audio file
        do {
            audioAVFile = try AVAudioFile(forReading: recorAudioURL as URL)
        } catch {
            showAlert(AlertViews.AudioAVFileError, message: String(describing: error))
        }
    }

    func playSound(rate: Float? = nil, pitch: Float? = nil, echo: Bool = false, reverb: Bool = false) {

        // initialize audio engine components
        audioAVEngine = AVAudioEngine()

        // node for playing audio
        audioPlAVNode = AVAudioPlayerNode()
        audioAVEngine.attach(audioPlAVNode)

        // node for adjusting rate/pitch
        let changeRatePitchNode = AVAudioUnitTimePitch()
        if let pitch = pitch {
            changeRatePitchNode.pitch = pitch
        }
        if let rate = rate {
            changeRatePitchNode.rate = rate
        }
        audioAVEngine.attach(changeRatePitchNode)

        // node for echo
        let echoNode = AVAudioUnitDistortion()
        echoNode.loadFactoryPreset(.multiEcho1)
        audioAVEngine.attach(echoNode)

        // node for reverb
        let reverbNode = AVAudioUnitReverb()
        reverbNode.loadFactoryPreset(.cathedral)
        reverbNode.wetDryMix = 50
        audioAVEngine.attach(reverbNode)

        // connect nodes
        if echo == true && reverb == true {
            connectAudioNodes(audioPlAVNode, changeRatePitchNode, echoNode, reverbNode, audioAVEngine.outputNode)
        } else if echo == true {
            connectAudioNodes(audioPlAVNode, changeRatePitchNode, echoNode, audioAVEngine.outputNode)
        } else if reverb == true {
            connectAudioNodes(audioPlAVNode, changeRatePitchNode, reverbNode, audioAVEngine.outputNode)
        } else {
            connectAudioNodes(audioPlAVNode, changeRatePitchNode, audioAVEngine.outputNode)
        }

        // schedule to play and start the engine!
        audioPlAVNode.stop()
        audioPlAVNode.scheduleFile(audioAVFile, at: nil) {

            var delayInSeconds: Double = 0

            if let lastRenderTime = self.audioPlAVNode.lastRenderTime, let playerTime = self.audioPlAVNode.playerTime(forNodeTime: lastRenderTime) {

                if let rate = rate {
                    delayInSeconds = Double(self.audioAVFile.length - playerTime.sampleTime) / Double(self.audioAVFile.processingFormat.sampleRate) / Double(rate)
                } else {
                    delayInSeconds = Double(self.audioAVFile.length - playerTime.sampleTime) / Double(self.audioAVFile.processingFormat.sampleRate)
                }
            }

            // schedule a stop timer for when audio finishes playing
            self.stopperTimer = Timer(timeInterval: delayInSeconds, target: self, selector: #selector(PlaySoundsViewController.stopAudio), userInfo: nil, repeats: false)
            RunLoop.main.add(self.stopperTimer!, forMode: RunLoopMode.defaultRunLoopMode)
        }

        do {
            try audioAVEngine.start()
        } catch {
            showAlert(AlertViews.AudioEnginerError, message: String(describing: error))
            return
        }

        // play the recording!
        audioPlAVNode.play()
    }

    @objc func stopAudio() {

        if let audioPlayerNode = audioPlAVNode {
            audioPlayerNode.stop()
        }

        if let stopTimer = stopperTimer {
            stopTimer.invalidate()
        }

        configureUI(.notPlaying)

        if let audioEngine = audioAVEngine {
            audioEngine.stop()
            audioEngine.reset()
        }
    }

    // MARK: Connect List of Audio Nodes

    func connectAudioNodes(_ nodes: AVAudioNode...) {
        for x in 0..<nodes.count-1 {
            audioAVEngine.connect(nodes[x], to: nodes[x+1], format: audioAVFile.processingFormat)
        }
    }

    // MARK: UI Functions

    func configureUI(_ playState: PlayingState) {
        switch(playState) {
        case .playing:
            setPlayButtonsEnabled(false)
            btnStop.isEnabled = true
        case .notPlaying:
            setPlayButtonsEnabled(true)
            btnStop.isEnabled = false
        }
    }

    func setPlayButtonsEnabled(_ enabled: Bool) {
        btnSnail.isEnabled = enabled
        btnChipmunk.isEnabled = enabled
        btnRabbit.isEnabled = enabled
        btnVader.isEnabled = enabled
        btnEcho.isEnabled = enabled
        btnReverb.isEnabled = enabled
    }

    func showAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: AlertViews.DmissAlert, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
