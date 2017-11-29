//
//  Sheets.swift
//  SwiftXLS
//
//  Created by Carl Wieland on 4/28/17.
//  Copyright © 2017 Datum. All rights reserved.
//

import Foundation

class Sheets: XMLElement {

    let relationships:Relationships

    var sheets = [Worksheet]()

    init() {
        relationships = Relationships(name:"workbook.xml.rels")
        super.init(name: "sheets", uri: nil)
    }

    init?(under path: URL, strings: SharedStrings, idMaps: [[String: String]]) {
        guard let newRels = Relationships(path: path.appendingPathComponent("_rels/workbook.xml.rels")) else {
            return nil
        }

        self.relationships = newRels

        let sheetPaths = newRels.relationships(of: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet")
        for sheetRelationship in sheetPaths {
            guard let sheetInfo = idMaps.first(where: { $0["r:id"] == sheetRelationship.id}),
                let name = sheetInfo["name"], let idStr = sheetInfo["sheetId"], let id = Int(idStr) else {
                continue
            }

            guard let newSheet = Worksheet(path: path.appendingPathComponent(sheetRelationship.target), sheetName: name, id: id, sharedStrings: strings) else {
                return nil
            }


            sheets.append(newSheet)

        }

        super.init(name: "sheets", uri: nil)

    }

    func loadSheets(under path: URL) -> Bool {

        return false
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
