//
//  QSIDataTests.swift
//  QSITests
//
//  Copyright © 2018 Siva Dayalan. All rights reserved.
//

import XCTest
@testable import QSI

class QSIDataTests: XCTestCase {
    
    func testValidWordData() {
        let data = """
                    {
                        "word": "hello",
                        "frequency": 2,
                    }
                    """.data(using: .utf8)!
        
        do {
            let _ = try JSONDecoder().decode(WordData.self, from: data)
        } catch let error {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testInvalidWordData() {
        let data = """
                    {
                        "word": "hello"
                    }
                    """.data(using: .utf8)!
        
        XCTAssertThrowsError(try JSONDecoder().decode(WordData.self, from: data))
    }
    
    func testValidQSIData() {
        let data = """
                    {
                        "dictionary": [
                        {
                            "word": "quantum inventions",
                            "frequency": 8
                        },
                        {
                            "word": "invention",
                            "frequency": 4
                        }]
                    }
                    """.data(using: .utf8)!
        
        do {
            let _ = try JSONDecoder().decode(QSIData.self, from: data)
        } catch let error {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testInValidQSIData() {
        let data = """
                    {
                        [
                        {
                            "word": "quantum inventions",
                            "frequency": 8
                        },
                        {
                            "word": "invention",
                            "frequency": 4
                        }]
                    }
                    """.data(using: .utf8)!
        
        XCTAssertThrowsError(try JSONDecoder().decode(QSIData.self, from: data))
    }
    
}
