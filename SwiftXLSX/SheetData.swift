//
//  SheetData.swift
//  SwiftXLS
//
//  Created by Carl Wieland on 4/28/17.
//  Copyright © 2017 Datum. All rights reserved.
//

import Foundation

class SheetData: XMLElement {
    
    let sharedStrings: SharedStrings
    
    init(sharedStrings: SharedStrings) {
        self.sharedStrings = sharedStrings
        super.init(name: "sheetData", uri: nil)
    }

    private var maxRow = 0

    func newRow() -> Row {
        let newRow = Row(id: maxRow, sharedStrings: sharedStrings)
        maxRow += 1

        addChild(newRow)
        return newRow
    }
    
}
