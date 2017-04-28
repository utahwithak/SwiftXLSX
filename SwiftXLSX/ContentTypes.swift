//
//  ContentTypes.swift
//  SwiftXLS
//
//  Created by Carl Wieland on 4/27/17.
//  Copyright © 2017 Datum. All rights reserved.
//

import Foundation

fileprivate protocol ContentType: XMLWritable {

}

fileprivate class OverrideType: XMLAttributeItem, ContentType {

    init(type: String, part: String) {
        super.init(name: "Override")
        add(value: .text(type), for: "ContentType")
        add(value: .text(part), for: "PartName")
    }

}

fileprivate class DefaultType: XMLAttributeItem, ContentType {

    init(type: String, fileExtension: String) {
        super.init(name: "Default")
        add(value: .text(type), for: "ContentType")
        add(value: .text(fileExtension), for: "Extension")

    }

}


class ContentTypes: XMLElement {

    private var types = [ContentType]()

    override var elementName: String {
        return "Types"
    }

    override init() {
        types.append(DefaultType(type: "application/xml", fileExtension: "xml"))
        types.append(DefaultType(type: "application/vnd.openxmlformats-package.relationships+xml", fileExtension: "rels"))
        types.append(DefaultType(type: "image/jpeg", fileExtension: "jpeg"))

    }

    func add(document: DocumentContentItem) {
        types.append(OverrideType(type: document.contentType, part: document.partName))
    }

    func write(under parentDir: URL) throws {

        let path = parentDir.appendingPathComponent("[Content_Types].xml")

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

    override func writeheaderAttributes(to handle: FileHandle) throws {
        try handle.write(string: "xmlns=\"http://schemas.openxmlformats.org/package/2006/content-types\"")
    }

    override func writeElements(to handle: FileHandle) throws {
        for type in types {
            try type.write(to: handle)
        }

    }
}
