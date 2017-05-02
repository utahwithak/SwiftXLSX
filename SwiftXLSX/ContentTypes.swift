//
//  ContentTypes.swift
//  SwiftXLS
//
//  Created by Carl Wieland on 4/27/17.
//  Copyright © 2017 Datum. All rights reserved.
//

import Foundation

fileprivate protocol ContentType {

}

fileprivate class OverrideType: XMLElement, ContentType {

    init(type: String, part: String) {
        super.init(name: "Override", uri: nil)
        addAttribute(name: "ContentType", value: type)
        addAttribute(name: "PartName", value: part)
    }

}

fileprivate class DefaultType: XMLElement, ContentType {

    init(type: String, fileExtension: String) {
        super.init(name: "Default", uri: nil)
        addAttribute(name:"ContentType", value: type)
        addAttribute(name:"Extension", value: fileExtension)
    }

}


class ContentTypes: XMLDocument {


    let root = XMLElement(name: "Types")

    override init() {
        root.addAttribute(name: "xmlns", value: "http://schemas.openxmlformats.org/package/2006/content-types")
        root.addChild(DefaultType(type: "application/xml", fileExtension: "xml"))
        root.addChild(DefaultType(type: "application/vnd.openxmlformats-package.relationships+xml", fileExtension: "rels"))
        root.addChild(DefaultType(type: "image/jpeg", fileExtension: "jpeg"))

        super.init()

        addChild(root)

        version = "1.0"
        characterEncoding = "UTF-8"
        isStandalone = true
    }

    func add(document: DocumentContentItem) {
        root.addChild(OverrideType(type: document.contentType, part: document.partName))
    }

    func write(under parentDir: URL) throws {

        let path = parentDir.appendingPathComponent("[Content_Types].xml")

        if FileManager.default.fileExists(atPath: path.path) {
            try FileManager.default.removeItem(at: path)
        }

        try xmlData.write(to: path)

    }
}
