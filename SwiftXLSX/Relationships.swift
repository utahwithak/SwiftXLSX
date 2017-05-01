//
//  Relationships.swift
//  SwiftXLS
//
//  Created by Carl Wieland on 4/28/17.
//  Copyright © 2017 Datum. All rights reserved.
//

import Foundation

class Relationships: XMLDocument {

    let root = XMLElement(name: "Relationships")

    init(name: String) {
        root.addAttribute(XMLAttribute(key: "xmlns", value: "http://schemas.openxmlformats.org/package/2006/relationships"))

        super.init(rootElement: root)
        self.name = name
    }

    func write(under parentDir: URL) throws {

        let subDir = parentDir.appendingPathComponent("_rels")
        try FileManager.default.createDirectory(at: subDir, withIntermediateDirectories: true, attributes: nil)
        let filePath = subDir.appendingPathComponent(name!)

        try xmlData.write(to: filePath)
    }

    func add(file: RelationshipItem) {
        addChild(Relationship(id: file.id, type: file.type, target: file.target))
    }
}
