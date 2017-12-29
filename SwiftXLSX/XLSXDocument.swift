//
//  Workbook.swift
//  SwiftXLS
//
//  Created by Carl Wieland on 4/18/17.
//  Copyright © 2017 Datum. All rights reserved.
//

import Foundation
import Compression

enum SwiftXLSX: Error {
    case failedToCreateArchive
    case archiveMissingFile
    case missingContent(String)
}

public class XLSXDocument {

    let contentTypes: ContentTypes

    let relationships: Relationships

    let workbook: Workbook

//    public override init() {
//
//        root.addAttribute(name:"xmlns", value:"http://schemas.openxmlformats.org/spreadsheetml/2006/main")
//        root.addAttribute(name:"xmlns:mc", value:"http://schemas.openxmlformats.org/markup-compatibility/2006")
//        root.addAttribute(name:"xmlns:r", value:"http://schemas.openxmlformats.org/officeDocument/2006/relationships")
//
//        sharedStrings = SharedStrings()
//
//        sheets = Sheets()
//        root.addChild(sheets)
//
//        relationShips = Relationships(name: ".rels")
//        contentTypes = ContentTypes()
//
//        super.init()
//
//        addChild(root)
//        version = "1.0"
//        characterEncoding = "UTF-8"
//        isStandalone = true
//
//        contentTypes.add(document: self)
//        relationShips.add(file: self)
//        contentTypes.add(document: sharedStrings)
//    }

    public init(path: URL) throws {

        guard let archive = Archive(url: path, accessMode: .read) else  {
            throw SwiftXLSX.failedToCreateArchive
        }

        guard let contentTypesArchive = archive["[Content_Types].xml"], let relationshipArchive = archive["_rels/.rels"] else {
            throw SwiftXLSX.archiveMissingFile
        }

        let contentDoc = try archive.extractAll(of: contentTypesArchive) { try XMLDocument(data: $0) }
        let relDoc = try archive.extractAll(of: relationshipArchive, handler: { try XMLDocument(data: $0 )})

        self.contentTypes = try ContentTypes(from: contentDoc)
        self.relationships = try Relationships(from: relDoc)

        guard let workbookRelationship = relationships.relationships(matching: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument").first else {
            throw SwiftXLSX.missingContent("Workbook Relationship")
        }

        workbook = try Workbook(from: workbookRelationship, in: archive)

    }

//    public func addSheet(named name: String) -> Worksheet {
//        let sheet = sheets.newSheet(named: name, sharedStrings: sharedStrings)
//        contentTypes.add(document: sheet)
//        return sheet
//    }

    public func save(to path: URL) throws {
//
//        let subCacheDirectory = "tmpDoc"
//        let tempDirURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("saveDir")
//
//        defer {
//            do {
//                try FileManager.default.removeItem(at: tempDirURL)
//            } catch {
//                print("Failed to clean up \(error)")
//            }
//        }
//
//        let fileManager = FileManager.default
//        try fileManager.createDirectory(at: tempDirURL, withIntermediateDirectories: true, attributes: nil)
//
//        let tmpPath = tempDirURL.appendingPathComponent(subCacheDirectory)
//        try fileManager.createDirectory(at: tmpPath, withIntermediateDirectories: true, attributes: nil)
//        try contentTypes.write(under: tmpPath)
//        try relationShips.write(under: tmpPath, fileName: "_rels/.rels")
//
//        let xlPath = tmpPath.appendingPathComponent("xl")
//        try fileManager.createDirectory(at: xlPath, withIntermediateDirectories: true, attributes: nil)
//
//        //workbook file
////        let workbookData = xmlData
////        try workbookData.write(to: xlPath.appendingPathComponent("workbook.xml"))
//
//        sharedStrings.id = "rId\(sheets.sheets.count + 1)"
//        sheets.relationships.add(file: sharedStrings)
//
//        try sheets.saveRelations(under: xlPath)
//        try sheets.saveSheets(under: xlPath)
//        // write at end
//        try sharedStrings.write(under: xlPath)
//
//        try fileManager.zipItem(at: xlPath, to: path)

    }

}

