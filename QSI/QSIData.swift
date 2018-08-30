//
//  QSIData.swift
//  QSI
//
//  Copyright © 2018 Siva Dayalan. All rights reserved.
//

import Foundation

struct QSIData: Decodable {
    let dictionary: [WordData]
}

struct WordData: Decodable {
    let word: String
    let frequency: Int
}
