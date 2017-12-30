//
//  Workbook.swift
//  SwiftXLSX
//
//  Created by Carl Wieland on 12/28/17.
//  Copyright © 2017 Datum. All rights reserved.
//

import Foundation

internal class Workbook {

    private let relationship: Relationship

    private let relationships: Relationships

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


        try sheetArray.children?.forEach{
            guard let sheet = $0 as? XMLElement,
                let name = sheet.attribute(forName: "name")?.stringValue,
                let rId = sheet.attribute(forName: "r:id")?.stringValue,
                let sheetId = sheet.attribute(forName: "sheetId")?.stringValue else {
                throw SwiftXLSX.missingContent("Invalid sheet xml in workbook")
            }

            let newSheet = Sheet(name: name, id: sheetId)

            guard let target = relationships.target(for: rId) else {
                throw SwiftXLSX.missingContent("missing Target in workbook rels")
            }

            try newSheet.load(target: target, in: archive, strings: sharedStrings)

            self.sheets.append(newSheet)

        }
    }

    internal func createSheet(named: String) -> Sheet {
        let newSheet = Sheet(name: named, id: "\(sheets.count + 1)")
        sheets.append(newSheet)
        return newSheet
    }

    internal func write(under path: URL, contents: ContentTypes) throws {
        let xlPath = path.appendingPathComponent("xl")

        try FileManager.default.createDirectory(at: xlPath, withIntermediateDirectories: true, attributes: nil)

        let worksheetsPath = xlPath.appendingPathComponent("worksheets")

        try FileManager.default.createDirectory(at: worksheetsPath, withIntermediateDirectories: true, attributes: nil)

        let sharedStrings = SharedStrings()
        try sharedStrings.prepareForWriting(under: xlPath)

        contents.add(document: sharedStrings)

        for sheet in sheets {
            contents.add(document: sheet)
            relationships.add(file: sheet)
            try sheet.write(under: worksheetsPath, strings: sharedStrings)

        }
        sharedStrings.finishWriting()

        _ = relationships.add(type:"http://schemas.openxmlformats.org/officeDocument/2006/relationships/sharedStrings", target: "sharedStrings.xml")
        try relationships.write(under: xlPath, fileName: "workbook.xml.rels")


        let path =  xlPath.appendingPathComponent("workbook.xml")

        FileManager.default.createFile(atPath: path.path, contents: nil, attributes: nil)
        let writeStream = try FileHandle(forWritingTo: path)

        try writeStream.write(string: "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?><workbook xmlns=\"http://schemas.openxmlformats.org/spreadsheetml/2006/main\" xmlns:mc=\"http://schemas.openxmlformats.org/markup-compatibility/2006\" xmlns:r=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships\"><sheets>")

        for sheet in sheets {
            try writeStream.write(string: "<sheet name=\"\(sheet.name)\" r:id=\"\(sheet.id)\" sheetId=\"\(sheet.sheetId)\"></sheet>")
        }


        try writeStream.write(string: "</sheets></workbook>")
        writeStream.closeFile()
    }
}

extension Workbook: DocumentContentItem {
    var contentType: String {
        return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"
    }

    var partName: String {
        return "/xl/workbook.xml"
    }
}
