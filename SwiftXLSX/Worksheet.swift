//
//  Worksheet.swift
//  SwiftXLS
//
//  Created by Carl Wieland on 4/28/17.
//  Copyright © 2017 Datum. All rights reserved.
//

import Foundation

public class Worksheet: XMLDocument {

    fileprivate let sheetName: String

    fileprivate let sheetId: Int

    private let data: SheetData
    private let root = XMLElement(name: "worksheet")

    internal init(sheetName: String, id: Int, sharedStrings: SharedStrings) {
        self.sheetName = sheetName
        self.sheetId = id
        data = SheetData(sharedStrings: sharedStrings)
        root.addChild(data)

        root.addAttribute(name:"xmlns", value:"http://schemas.openxmlformats.org/spreadsheetml/2006/main")
        root.addAttribute(name:"xmlns:r", value:"http://schemas.openxmlformats.org/officeDocument/2006/relationships")
        root.addAttribute(name:"xmlns:mc", value:"http://schemas.openxmlformats.org/markup-compatibility/2006")
        root.addAttribute(name:"mc:Ignorable", value:"x14ac")
        root.addAttribute(name:"xmlns:x14ac", value:"http://schemas.microsoft.com/office/spreadsheetml/2009/9/ac")

        super.init()

        addChild(root)
        version = "1.0"
        characterEncoding = "UTF-8"
        isStandalone = true
    }

    func sheetElement() -> XMLElement {
        let sheet = XMLElement(name: "sheet")
        sheet.addAttribute(name: "name", value: sheetName)
        sheet.addAttribute(name: "r:id", value: "rId\(sheetId)")
        sheet.addAttribute(name: "sheetId", value: "\(sheetId)")
        return sheet

    }

    func write(under parentDir: URL) throws {
        let path = parentDir.appendingPathComponent("sheet\(sheetId).xml")

        if FileManager.default.fileExists(atPath: path.path) {
            try FileManager.default.removeItem(at: path)
        }
        let data = xmlData
        try data.write(to: path)
    }

    public func addRow() -> Row {
        return data.newRow()
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
