//
//  Workbook.swift
//  SwiftXLSX
//
//  Created by Carl Wieland on 12/28/17.
//  Copyright © 2017 Datum. All rights reserved.
//

import Foundation

class Workbook {

    let relationship: Relationship

    let relationships: Relationships

    public var sheets = [Sheet]()


    init(in rels: Relationships) {
        relationship = rels.add(type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument", target: "xl/workbook.xml")
        relationships = Relationships()
    }

    internal init(from relationship: Relationship, in archive: Archive) throws {
        self.relationship = relationship

        relationships = try Relationships(from: try archive.extractAll(of: "xl/_rels/workbook.xml.rels"))

        let sharedStrings = try SharedStrings(from: try archive.extractAll(of: "xl/sharedStrings.xml"))


        let workbookDocument = try archive.extractAll(of: relationship.target)
        guard let workbook = workbookDocument.children?.first(where: { $0.name == "workbook"}) as? XMLElement, let sheetArray = workbook.children?.first(where: { $0.name == "sheets"}) else {
            throw SwiftXLSX.missingContent("Missign sheets data")
        }


        if let sheets = sheetArray.children as? [XMLElement] {
            for sheet in sheets {
                guard let name = sheet.attribute(forName: "name")?.stringValue,
                    let rId = sheet.attribute(forName: "r:id")?.stringValue,
                    let sheetId = sheet.attribute(forName: "sheetId")?.stringValue else {
                    throw SwiftXLSX.missingContent("Invalid sheet xml in workbook")
                }
                
                let newSheet = Sheet(name: name, id: sheetId, workbook: self)

                guard let target = relationships.target(for: rId) else {
                    throw SwiftXLSX.missingContent("missing Target in workbook rels")
                }

                try newSheet.load(target: target, in: archive, strings: sharedStrings)

                self.sheets.append(newSheet)
            }


        }
    }
}
