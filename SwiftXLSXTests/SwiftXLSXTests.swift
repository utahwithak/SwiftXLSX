//
//  SwiftXLSXTests.swift
//  SwiftXLSXTests
//
//  Created by Carl Wieland on 4/28/17.
//  Copyright © 2017 Datum. All rights reserved.
//

import XCTest
@testable import SwiftXLSX

class SwiftXLSXTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    
    func testSimpleInit() {
        let bundle = Bundle(for: type(of:self))
        guard let url = bundle.url(forResource: "Book1", withExtension: "xlsx") else {
            XCTFail()
            return
        }

        do{
            let wb = try XLSXDocument(path: url)
            print("wb: \(wb)")
        }  catch  {
            print("Failed to create workbook:\(error)")
            XCTFail()
        }

    }
    
    func testMainXLSXPerformance() {
        let bundle = Bundle(for: type(of:self))
        guard let url = bundle.url(forResource: "mainXLSX", withExtension: "xlsx") else {
            XCTFail()
            return
        }

//
//        self.measure {
//            do{
//                let wb = try Workbook(path: url)
//                print("wb: \(wb)")
//            }  catch  {
//                XCTFail()
//            }
//
//        }
    }
    
}
