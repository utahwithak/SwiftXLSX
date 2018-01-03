//
//  SheetData.swift
//  SwiftXLS
//
//  Created by Carl Wieland on 4/28/17.
//  Copyright © 2017 Datum. All rights reserved.
//

import Foundation

public class Sheet {

    public let name: String
    let sheetId: String

    private var rows = [Row]()

    internal init(name: String, id: String) {
        self.name = name
        self.sheetId = id
    }

    private var maxRow = 0

    private var currentRow: Row?

    public func addRow() -> Row {
        let newRow = Row(id: rows.count)
        rows.append(newRow)
        return newRow
    }

    internal func load(target: String, in archive: Archive, strings: SharedStrings) throws {
        let document = try archive.extractAll(of: "xl/\(target)")
        guard let worksheet = document.children?.first(where: { $0.name == "worksheet" }) as? XMLElement else {
            throw SwiftXLSX.missingContent("Missing worksheet node")
        }

        guard let sheetData = worksheet.children?.first(where: { $0.name == "sheetData"}) as? XMLElement else {
            throw SwiftXLSX.missingContent("Sheet data missing")
        }


        try sheetData.children?.forEach({ element in
            if let rowElement = element as? XMLElement {
                let newRow = try Row(from: rowElement, strings: strings)
                self.rows.append(newRow)
            }
        })


    }

    public func flatData() -> [[XLSXExpressible?]]? {
    
        let maxColCount = rows.reduce(0, {max($0, $1.maxColumnCount)})

        return rows.map({ $0.rowData(paddedTo: maxColCount)})

    }

    internal func write(under parentFolder: URL, strings: SharedStrings) throws {
        let path = parentFolder.appendingPathComponent("sheet\(sheetId).xml")

        FileManager.default.createFile(atPath: path.path, contents: nil, attributes: nil)
        let writeStream = try FileHandle(forWritingTo: path)
        try writeStream.write(string: "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?><worksheet xmlns=\"http://schemas.openxmlformats.org/spreadsheetml/2006/main\" xmlns:r=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships\" xmlns:mc=\"http://schemas.openxmlformats.org/markup-compatibility/2006\" mc:Ignorable=\"\" xmlns:x14ac=\"http://schemas.microsoft.com/office/spreadsheetml/2009/9/ac\"><sheetData>")

        for row in rows {
            try row.write(to: writeStream, with: strings)
        }

        try writeStream.write(string: "</sheetData></worksheet>")
        writeStream.closeFile()
    }

}

extension Sheet: DocumentContentItem {

    var contentType: String {
        return "application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"
    }

    var partName: String {
        return "/xl/worksheets/sheet\(sheetId).xml"
    }
}

extension Sheet: RelationshipItem {
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

