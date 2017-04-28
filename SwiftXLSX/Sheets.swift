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

    override init() {
        super.init()
    }

    override var elementName: String {
        return "sheets"
    }

    override func writeElements(to handle: FileHandle) throws {
        for sheet in sheets {
            try sheet.writeAsAttributeItem(to: handle)
        }
    }


    func newSheet(named name: String, sharedStrings: SharedStrings) -> Worksheet {

        let newSheet = Worksheet(sheetName: name, id: sheets.count + 1, sharedStrings: sharedStrings)
        sheets.append(newSheet)
        relationships.add(file: newSheet)
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
