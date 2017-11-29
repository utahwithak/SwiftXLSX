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

        guard Workbook(path: url) != nil else {
            XCTFail()
            return
        }

    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
