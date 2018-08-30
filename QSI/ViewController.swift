//
//  ViewController.swift
//  QSI
//
//  Copyright © 2018 Siva Dayalan. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController {
    
    @IBOutlet private weak var speakButton: UIButton!
    @IBOutlet private weak var textLabel: UILabel!
    
    fileprivate var wordData: [WordData]?
    fileprivate let audioEngine = AVAudioEngine()
    fileprivate let request = SFSpeechAudioBufferRecognitionRequest()
    fileprivate var recongnitionTask: SFSpeechRecognitionTask?

    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveData()
        requestSpeechAuthorization()
    }
    
    @IBAction private func speakButtonTapped(_ sender: UIButton) {
        if audioEngine.isRunning {
            speakButton.setTitle("Speak", for: .normal)
            textLabel.text = ""
            cancelRecording()
        } else {
            speakButton.setTitle("Stop", for: .normal)
            recordAndRecognize()
        }
    }
}

// MARK: - Data Retrieval
extension ViewController {
    
    /// Retrieve QSIData
    fileprivate func retrieveData() {
        
        if let url = URL(string: "http://a.galactio.com/interview/dictionary-v2.json") {
            let request = NSMutableURLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = [
                "Cache-Control": "no-cache",
            ]
            
            let session = URLSession.shared
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                if let `error` = error {
                    print(error.localizedDescription)
                }
                
                if let `data` = data {
                    do {
                        let qsiData = try JSONDecoder().decode(QSIData.self, from: data)
                        self.wordData = qsiData.dictionary
                    } catch let error {
                        print(error.localizedDescription)
                    }
                }
            })
            
            dataTask.resume()
        }
    }
}

// MARK: - Speech Recognition & Recording
extension ViewController {
    
    /// Request Speech Recognizer Authorization to update UI
    fileprivate func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { (status) in
            OperationQueue.main.addOperation {
                switch status {
                case .authorized:
                    self.speakButton.isEnabled = true
                case .denied:
                    self.speakButton.isEnabled = false
                    self.textLabel.text = "User denied access to use speech recognition"
                case .notDetermined:
                    self.speakButton.isEnabled = false
                    self.textLabel.text = "Speech recognition is not authorized"
                case .restricted:
                    self.speakButton.isEnabled = false
                    self.textLabel.text = "Speech recognition is restricted on this device"
                }
            }
        }
    }
    
    /// Record the voice and process Speech Rocognition
    fileprivate func recordAndRecognize() {
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request.append(buffer)
        }
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch let error {
            print(error.localizedDescription)
        }
        
        guard let myRecognizer = SFSpeechRecognizer() else {
            return
        }
        
        if !myRecognizer.isAvailable {
            print("Recognizer is not available")
            return
        }
        
        recongnitionTask = myRecognizer.recognitionTask(with: request, resultHandler: { result, error in
            if let `result` = result {
                self.textLabel.text = result.bestTranscription.formattedString
            }
            
            if let `error` = error {
                print(error.localizedDescription)
            }
        })
    }
    
    /// Cancel Voice Recording
    fileprivate func cancelRecording() {
        audioEngine.stop()
        request.endAudio()
        audioEngine.inputNode.removeTap(onBus: 0);
    }
}

