//
//  SharedStrings.swift
//  SwiftXLSX
//
//  Created by Carl Wieland on 4/28/17.
//  Copyright © 2017 Datum. All rights reserved.
//

import Foundation

class SharedStrings: XMLDocument {

    let root = XMLElement(name: "sst")
    override init() {

        root.addAttribute(XMLAttribute(key:"xmlns", value: "http://schemas.openxmlformats.org/spreadsheetml/2006/main"))

        super.init(rootElement: root)
        version = "1.0"
        characterEncoding = "UTF-8"
        isStandalone = true
    }

    private var strings = [SharedString]()

    func add(_ value: String) -> Int {
        let index = strings.count
        strings.append(SharedString(text: value))
        return index
    }
    var id: String = "rId0"

    func write(under parentDir: URL) throws {
        let path = parentDir.appendingPathComponent("sharedStrings.xml")

        if FileManager.default.fileExists(atPath: path.path) {
            try FileManager.default.removeItem(at: path)
        }

        let data = xmlData
        try data.write(to: path)
    }

    func removeShared(at index: Int) {
        strings.remove(at: index)
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
    init(text: String) {
        super.init(name: "si", uri: nil)
        addChild(SimpleElement(name: "t", value: text))

    }
}
