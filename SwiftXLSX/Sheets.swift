//
//  Sheets.swift
//  SwiftXLS
//
//  Created by Carl Wieland on 4/28/17.
//  Copyright © 2017 Datum. All rights reserved.
//

import Foundation

class Sheets: XMLElement {

    let relationships = Relationships(name:"workbook.xml.rels")

    var sheets = [Worksheet]()

    init() {
        super.init(name: "sheets", uri: nil)
    }

    func newSheet(named name: String, sharedStrings: SharedStrings) -> Worksheet {

        let newSheet = Worksheet(sheetName: name, id: sheets.count + 1, sharedStrings: sharedStrings)
        sheets.append(newSheet)
        relationships.add(file: newSheet)
        addChild(newSheet.sheetElement())
        return newSheet

    }

    func saveRelations(under parentDir: URL) throws {
        try relationships.write(under: parentDir)
    }

    func saveSheets(under parentDir: URL) throws {
        let sheetDir = parentDir.appendingPathComponent("worksheets")
        try FileManager.default.createDirectory(at: sheetDir, withIntermediateDirectories: true, attributes: nil)

        for sheet in sheets {
            try sheet.write(under: sheetDir)
        }

    }

    
}
