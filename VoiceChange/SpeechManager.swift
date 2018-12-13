//
//  SpeechManager.swift
//  VoiceChange
//
//  Created by mac on 10/8/18.
//  Copyright © 2018 mac. All rights reserved.
//

import Foundation
import Speech

@objc protocol SpeechManagerDelegate:class {
    
    func onError(message:String)
   func onSuccess(convertedText:String)
}

class SpeechManager {
    
    weak var delegate : SpeechManagerDelegate?
    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()

    
    var recognitionTask: SFSpeechRecognitionTask?
    var node : AVAudioInputNode?
    func recordSpeech(request:SFSpeechAudioBufferRecognitionRequest) {
        
        self.node = audioEngine.inputNode
        let recordingFormat = node?.outputFormat(forBus: 0)
        node?.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat)  {  buffer, _ in
            request.append(buffer)
        }
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            self.delegate?.onError(message: "There has been an audio engine error.")
            return print(error)
        }
    }
    
   
    func stopRecording() {
        audioEngine.stop()
        if let node = node {
            node.removeTap(onBus: 0)
            self.node = nil
        }
        recognitionTask?.cancel()
        
    }
    
    func recogizerAvailable() -> Bool {
        
        guard let voiceRecognizer = SFSpeechRecognizer() else {
            self.delegate?.onError(message: "Speech recognition is not supported for your current locale.")
            return false
        }
        if !voiceRecognizer.isAvailable {
            self.delegate?.onError(message: "Speech recognition is not currently available. Check back at a later time.")
            
            return false
        }
        return true
    }
    
    func recognizeSpeech() {
    
        if  recogizerAvailable() && self.node == nil {
            let request = SFSpeechAudioBufferRecognitionRequest()
            recordSpeech(request: request)
            recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { [weak self] result, error in
                if let result = result {
                    
                    let bestString = result.bestTranscription.formattedString
                    
                    self?.delegate?.onSuccess(convertedText: bestString)
                    
                } else if let error = error {
                    self?.delegate?.onError(message: "There has been a speech recognition error.")
                    print(error)
                }
            })
        }
        else {
            
            self.delegate?.onError(message: "speech recognition up and running.")
        }
       
    }
    
    func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    break
                case .denied:
                       self.delegate?.onError(message: "User denied access to speech recognition")
                   
                case .restricted:
                    self.delegate?.onError(message: "Speech recognition restricted on this device")
                  
                case .notDetermined:
                    self.delegate?.onError(message: "Speech recognition not yet authorized")

                }
            }
        }
    }
}
