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
    @IBOutlet private weak var tableView: UITableView!
    
    fileprivate var wordData = [WordData]()
    fileprivate let audioEngine = AVAudioEngine()
    fileprivate let request = SFSpeechAudioBufferRecognitionRequest()
    fileprivate var recongnitionTask: SFSpeechRecognitionTask?

    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveData()
        tableView.delegate = self
        tableView.dataSource = self
        requestSpeechAuthorization()
    }
    
    @IBAction private func speakButtonTapped(_ sender: UIButton) {
        // Tap on Speak to record the voice, stop to recognize. This will ensure we can handle word & phrases
        if audioEngine.isRunning {
            speakButton.setTitle("Speak", for: .normal)
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
                        self.wordData = qsiData.sorted
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    } catch let error {
                        print(error.localizedDescription)
                    }
                }
            })
            
            dataTask.resume()
        }
    }
}

// MARK: - Update tableView when spoken phrase is a match
extension ViewController {
    
    fileprivate func match(_ text: String) {
        if let index = wordData.index(where: { $0.word.lowercased() == text.lowercased() }) {
            wordData[index].frequency += 1
            wordData = wordData.sorted(by: { $0.frequency > $1.frequency })
            tableView.reloadData()
        } else {
            textLabel.text = "\(text) is not available"
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
                let resultString = result.bestTranscription.formattedString
                self.textLabel.text = resultString
                self.match(resultString)
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
        textLabel.text = ""
    }
}

extension ViewController: UITableViewDelegate {
    // To-Do
}

extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wordData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let textCellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath) as! TableViewCell
        
        let row = indexPath.row
        cell.wordLabel.text = wordData[row].word
        cell.frequencyLabel.text = "\(wordData[row].frequency)"
        
        return cell
    }
}

