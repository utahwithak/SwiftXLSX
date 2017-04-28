//
//  Worksheet.swift
//  SwiftXLS
//
//  Created by Carl Wieland on 4/28/17.
//  Copyright © 2017 Datum. All rights reserved.
//

import Foundation

public class Worksheet: XMLElement {

    let sheetName: String

    let sheetId: Int

    let data = SheetData()

    internal init(sheetName: String, id: Int) {
        self.sheetName = sheetName
        self.sheetId = id
    }

    internal func writeAsAttributeItem(to handle: FileHandle) throws {
        try handle.write(string: "<sheet name=\"")
        try sheetName.write(to: handle)
        try handle.write(string: "\" r:id=\"rId\(sheetId)\" sheetId=\"\(sheetId)\"/>")
    }

    override var elementName: String {
        return "worksheet"
    }
    
    override func writeheaderAttributes(to handle: FileHandle) throws {
        try handle.write(string: "xmlns=\"http://schemas.openxmlformats.org/spreadsheetml/2006/main\" xmlns:r=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships\" xmlns:mc=\"http://schemas.openxmlformats.org/markup-compatibility/2006\" mc:Ignorable=\"x14ac\" xmlns:x14ac=\"http://schemas.microsoft.com/office/spreadsheetml/2009/9/ac\"")
    }

    func write(under parentDir: URL) throws {
        let path = parentDir.appendingPathComponent("sheet\(sheetId).xml")

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

    override func writeElements(to handle: FileHandle) throws {
        try data.write(to: handle)
    }
}

extension Worksheet: DocumentContentItem {

    var contentType: String {
        return "application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"
    }

    var partName: String {
        return "/xl/worksheets/sheet\(sheetId).xml"
    }
}

extension Worksheet: RelationshipItem {
    var id: String {
        return "rId\(sheetId)"
    }

    var type: String {
        return "http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet"
    }

    var target: String {
        return "worksheets/sheet\(sheetId).xml"
    }
}
