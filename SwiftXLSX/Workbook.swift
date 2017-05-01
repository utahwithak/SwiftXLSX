//
//  Workbook.swift
//  SwiftXLS
//
//  Created by Carl Wieland on 4/18/17.
//  Copyright © 2017 Datum. All rights reserved.
//

import Foundation
import Zip

public class Workbook: XMLElement  {

    let contentTypes: ContentTypes

    let relationShips: Relationships

    let sheets: Sheets

    let sharedStrings = SharedStrings()

    var id: String = "rId1"

    public override init() {
        sheets = Sheets()
        relationShips = Relationships(name: ".rels")
        contentTypes = ContentTypes()

        super.init()

        contentTypes.add(document: self)
        relationShips.add(file: self)
        contentTypes.add(document: sharedStrings)
    }


    deinit {

    }


    public func addSheet(named name: String) -> Worksheet {
        let sheet = sheets.newSheet(named: name, sharedStrings: sharedStrings)
        contentTypes.add(document: sheet)
        return sheet
    }

    public func save(to path: URL) throws {

        let subCacheDirectory = "tmpDoc"
        let tempDirURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("saveDir")

        defer {
            do {
                try FileManager.default.removeItem(at: tempDirURL)
            } catch {
                print("Failed to clean up \(error)")
            }
        }

        try FileManager.default.createDirectory(at: tempDirURL, withIntermediateDirectories: true, attributes: nil)

        let tmpPath = tempDirURL.appendingPathComponent(subCacheDirectory)
        try FileManager.default.createDirectory(at: tmpPath, withIntermediateDirectories: true, attributes: nil)
        try contentTypes.write(under: tmpPath)
        try relationShips.write(under: tmpPath)

        let xlPath = tmpPath.appendingPathComponent("xl")
        try FileManager.default.createDirectory(at: xlPath, withIntermediateDirectories: true, attributes: nil)

        //workbook file
        try saveWorkbookXML(to: xlPath.appendingPathComponent("workbook.xml"))
        sharedStrings.id = "rId\(sheets.sheets.count + 1)"
        sheets.relationships.add(file: sharedStrings)

        try sheets.saveRelations(under: xlPath)
        try sheets.saveSheets(under: xlPath)
        // write at end
        try sharedStrings.write(under: xlPath)

        try Zip.zipFiles(under: tmpPath, to: path)
    }


    override func writeheaderAttributes(to handle: FileHandle) throws {
        try handle.write(string: " xmlns=\"http://schemas.openxmlformats.org/spreadsheetml/2006/main\" xmlns:mc=\"http://schemas.openxmlformats.org/markup-compatibility/2006\" xmlns:r=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships\"")
    }

    override func writeElements(to handle: FileHandle) throws {
        try sheets.write(to: handle)
    }

    private func saveWorkbookXML(to path: URL) throws {
        if FileManager.default.fileExists(atPath: path.path) {
            try FileManager.default.removeItem(at: path)
        }

        guard FileManager.default.createFile(atPath: path.path, contents: nil, attributes: nil) else {
            throw NSError(domain: "com.datum.SwiftXLS", code: 6, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Unable to Create file", comment: "Create file error")])
        }
        let fileHandle = try FileHandle(forWritingTo: path)
        try fileHandle.writeXMLHeader()
        try write(to: fileHandle)
    }



    override var elementName: String {
        return "workbook"
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

extension Workbook: RelationshipItem {

    var type: String { return "http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" }
    var target: String { return "xl/workbook.xml" }
}
