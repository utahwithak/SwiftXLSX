//
//  SharedStrings.swift
//  SwiftXLSX
//
//  Created by Carl Wieland on 4/28/17.
//  Copyright © 2017 Datum. All rights reserved.
//

import Foundation

class SharedStrings: XMLElement {
    private var strings = [SharedString]()

    func add(_ value: String) -> Int {
        let index = strings.count
        strings.append(SharedString(text: value))
        return index
    }
    var id: String = "rId0"

    override var elementName: String {
        return "sst"
    }

    override func writeheaderAttributes(to handle: FileHandle) throws {
        try handle.write(string: " xmlns=\"http://schemas.openxmlformats.org/spreadsheetml/2006/main\"")
    }

    func write(under parentDir: URL) throws {
        let path = parentDir.appendingPathComponent("sharedStrings.xml")

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
        for str in strings {
            try str.write(to: handle)
        }
    }

}

extension SharedStrings: DocumentContentItem {
    var contentType: String {
        return "application/vnd.openxmlformats-officedocument.spreadsheetml.sharedStrings+xml"
    }
    var partName: String {
        return "/xl/sharedStrings.xml"
    }
}

extension SharedStrings: RelationshipItem {

    var target: String {
        return "sharedStrings.xml"
    }

    var type: String {
        return "http://schemas.openxmlformats.org/officeDocument/2006/relationships/sharedStrings"
    }
}

fileprivate class SharedString: XMLElement {
    let stringValue: String
    init(text: String) {
        self.stringValue = text
    }

    override var elementName: String {
        return "si"
    }

    override func writeElements(to handle: FileHandle) throws {
        try handle.write(string: "<t>")
        try stringValue.write(to: handle)
        try handle.write(string: "</t>")
    }
}
