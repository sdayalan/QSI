//
//  ViewController.swift
//  QSI
//
//  Copyright © 2018 Siva Dayalan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    fileprivate var wordData: [WordData]?

    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveData()
    }
}

// MARK: - Data Retrieval
extension ViewController {
    
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

