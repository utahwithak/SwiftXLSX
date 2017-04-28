//
//  SheetData.swift
//  SwiftXLS
//
//  Created by Carl Wieland on 4/28/17.
//  Copyright © 2017 Datum. All rights reserved.
//

import Foundation

class SheetData: XMLElement {

    var rows = [Row]()

    let sharedStrings: SharedStrings
    
    init(sharedStrings: SharedStrings) {
        self.sharedStrings = sharedStrings
        super.init()
    }

    private var maxRow = 0

    override var isEmpty: Bool {
         return rows.reduce(true, { $0 && $1.isEmpty })
    }
    
    override var elementName: String {
        return "sheetData"
    }

    func newRow() -> Row {
        let newRow = Row(id: maxRow, sharedStrings: sharedStrings)
        maxRow += 1
        rows.append(newRow)
        return newRow
    }
    
    override func writeElements(to handle: FileHandle) throws {
        for row in rows {
            try row.write(to: handle)
        }
    }
}
