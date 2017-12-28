//
//  Workbook.swift
//  SwiftXLS
//
//  Created by Carl Wieland on 4/18/17.
//  Copyright © 2017 Datum. All rights reserved.
//

import Foundation
import Zip

public class Workbook: XMLDocument  {

    let contentTypes: ContentTypes

    let relationShips: Relationships

    public let sheets: Sheets

    let sharedStrings: SharedStrings

    var id: String = "rId1"

    let root = XMLElement(name:"workbook")

    override public func rootElement() -> XMLElement? {
        return root
    }

    public override init() {

        root.addAttribute(name:"xmlns", value:"http://schemas.openxmlformats.org/spreadsheetml/2006/main")
        root.addAttribute(name:"xmlns:mc", value:"http://schemas.openxmlformats.org/markup-compatibility/2006")
        root.addAttribute(name:"xmlns:r", value:"http://schemas.openxmlformats.org/officeDocument/2006/relationships")

        sharedStrings = SharedStrings()

        sheets = Sheets()
        root.addChild(sheets)
        
        relationShips = Relationships(name: ".rels")
        contentTypes = ContentTypes()

        super.init()
        
        addChild(root)
        version = "1.0"
        characterEncoding = "UTF-8"
        isStandalone = true

        contentTypes.add(document: self)
        relationShips.add(file: self)
        contentTypes.add(document: sharedStrings)
    }

    public init?(path: URL, password: String? = nil) {

        Zip.addCustomFileExtension(path.pathExtension)

        let subCacheDirectory = "tmpDoc"
        let tempDirURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("saveDir")
        defer {
            do {
                try FileManager.default.removeItem(at: tempDirURL)
            } catch {
                print("Failed to clean up \(error)")
            }
        }

        do {
            try Zip.unzipFile(path, destination: tempDirURL, overwrite: true, password: password, progress: nil)
        } catch {
            print("Failed to unzip to temp dir:\(error)")
            return nil
        }

        guard let contentTypes = ContentTypes(under: tempDirURL), let rels = Relationships(path: tempDirURL.appendingPathComponent("_rels/.rels")) else {
            return nil
        }

        self.contentTypes = contentTypes
        relationShips = rels

        let xlPath =  tempDirURL.appendingPathComponent("xl", isDirectory: true)

        let worksheetURL = xlPath.appendingPathComponent("workbook.xml")
        guard let doc = try? XMLDocument(contentsOf: worksheetURL, options: []), let workbookSheets = doc.children?.first?.children?.first(where: { $0.name == "sheets"}) else {
            return nil
        }

        guard let xmlNodes = workbookSheets.children?.flatMap({ ($0 as? XMLElement)?.attributes}) else {
            return nil
        }

        var sheetAttributes = [[String: String]]()
        for nodeVals in xmlNodes {
            var attrs = [String: String]()
            for node in nodeVals {
                if let name = node.name {
                    attrs[name] = node.stringValue
                }
            }

            sheetAttributes.append(attrs)
        }

        guard let strings = SharedStrings(under: xlPath), let sheets = Sheets(under: xlPath, strings: strings, idMaps: sheetAttributes) else {
            return nil
        }

        self.sharedStrings = strings
        self.sheets = sheets

        root.addAttribute(name:"xmlns", value:"http://schemas.openxmlformats.org/spreadsheetml/2006/main")
        root.addAttribute(name:"xmlns:mc", value:"http://schemas.openxmlformats.org/markup-compatibility/2006")
        root.addAttribute(name:"xmlns:r", value:"http://schemas.openxmlformats.org/officeDocument/2006/relationships")

        root.addChild(sheets)

        
        super.init()

        version = "1.0"
        characterEncoding = "UTF-8"
        isStandalone = true


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
        let workbookData = xmlData
        try workbookData.write(to: xlPath.appendingPathComponent("workbook.xml"))

        sharedStrings.id = "rId\(sheets.sheets.count + 1)"
        sheets.relationships.add(file: sharedStrings)

        try sheets.saveRelations(under: xlPath)
        try sheets.saveSheets(under: xlPath)
        // write at end
        try sharedStrings.write(under: xlPath)

        try Zip.zipFiles(under: tmpPath, to: path)
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
