//
//  QSIData.swift
//  QSI
//
//  Copyright © 2018 Siva Dayalan. All rights reserved.
//

import Foundation

struct QSIData: Decodable {
    let dictionary: [WordData]
    
    var sorted: [WordData] {
        return dictionary.sorted(by: { $0.frequency > $1.frequency })
    }
}

struct WordData: Decodable {
    let word: String
    let frequency: Int
}
