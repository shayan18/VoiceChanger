//
//  ViewController.swift
//  VoiceChange
//
//  Created by mac on 10/8/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController {

    @IBOutlet weak var voiceTextView: UITextView!
    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var utterance = AVSpeechUtterance()
    var requesturl =  SFSpeechURLRecognitionRequest.init(url: URL(fileURLWithPath: Bundle.main.path(forResource: "1", ofType: "mp3")!)
)
    var voiceGender : String = "en-US"
    var recognitionTask: SFSpeechRecognitionTask?
    var isRecording = false
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    func recordAndRecognizeSpeech() {
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            //self.request.append(buffer)
        }
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            self.sendAlert(message: "There has been an audio engine error.")
            return print(error)
        }
        guard let myRecognizer = SFSpeechRecognizer() else {
            self.sendAlert(message: "Speech recognition is not supported for your current locale.")
            return
        }
        if !myRecognizer.isAvailable {
            self.sendAlert(message: "Speech recognition is not currently available. Check back at a later time.")
            // Recognizer is not available right now
            return
        }
        recognitionTask = speechRecognizer?.recognitionTask(with: requesturl, resultHandler: { result, error in
            if let result = result {
                
                let bestString = result.bestTranscription.formattedString
                self.voiceTextView.text = bestString
                
                var lastString: String = ""
                for segment in result.bestTranscription.segments {
                    let indexTo = bestString.index(bestString.startIndex, offsetBy: segment.substringRange.location)
                    lastString = bestString.substring(from: indexTo)
                }
            } else if let error = error {
                self.sendAlert(message: "There has been a speech recognition error.")
                print(error)
            }
        })
    }
    @IBAction func voiceToText(_ sender: Any) {
        
        if isRecording == true {
            audioEngine.stop()
            recognitionTask?.cancel()
            isRecording = false
        } else {
            self.recordAndRecognizeSpeech()
            isRecording = true
          
        }
       
    }
    
    
    @IBAction func textToSpeach(_ sender: UIButton) {
        
        utterance = AVSpeechUtterance(string: voiceTextView.text)
          utterance.voice = AVSpeechSynthesisVoice(language: voiceGender)
        let synth = AVSpeechSynthesizer()
        //utterance.rate = 0.45
        utterance.volume = 1.0
   
       let voices = AVSpeechSynthesisVoice.speechVoices()
        print(voices)
        
        synth.speak(utterance)
    }
    @IBAction func maleButtonTapped(_ sender: UIButton) {
        voiceGender = "en-GB"
   
    }
    @IBAction func femaleButtonTapped(_ sender: UIButton) {
         voiceGender = "en-US"
    }
    @IBAction func changeVoice(_ sender: Any) {
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func sendAlert(message: String) {
        let alert = UIAlertController(title: "Speech Recognizer Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

