//
//  SpeechViewController.swift
//  VoiceChange
//
//  Created by mac on 10/8/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit

class SpeechViewController: UIViewController {

    @IBOutlet weak var voiceTextView: UITextView!
    let speechManager = SpeechManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        speechManager.delegate = self
    }

 
    @IBAction func voiceToText(_ sender: UIButton) {
        
        speechManager.recognizeSpeech()
    }
    @IBAction func textToSpeech(_ sender: Any) {
        
        
    }
}

extension SpeechViewController : SpeechManagerDelegate {
    func onError(message: String) {
        
        self.sendAlert(message: message)
    }
    
    func onSuccess(convertedText: String) {
        
        voiceTextView.text = convertedText
    }
    
    

    
    
    func sendAlert(message: String) {
        let alert = UIAlertController(title: "Speech Recognizer Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
