//
//  Relationships.swift
//  SwiftXLS
//
//  Created by Carl Wieland on 4/28/17.
//  Copyright © 2017 Datum. All rights reserved.
//

import Foundation
class Relationship: XMLElement {

    init(id: String, type: String, target: String) {
        super.init(name: "Relationship", uri: nil)
        addAttribute(name: "Id", value: id)
        addAttribute(name: "Type", value: type)
        addAttribute(name: "Target", value: target)
    }

    init(attributes: [String: String]) {
        super.init(name: "Relationship", uri: nil)
        for (key, value) in attributes {
            addAttribute(name: key, value: value)
        }
    }

    var id: String {
        return attribute(forName: "Id")?.stringValue ?? ""
    }
    var type: String {
        return attribute(forName: "Type")?.stringValue ?? ""
    }
    var target: String {
        return attribute(forName: "Target")?.stringValue ?? ""
    }

}

class Relationships: XMLDocument {

    let fileName: String

    let root = XMLElement(name: "Relationships")

    override func rootElement() -> XMLElement? {
        return root
    }

    init(name: String) {
        fileName = name
        root.addAttribute(name: "xmlns", value: "http://schemas.openxmlformats.org/package/2006/relationships")

        super.init()
        addChild(root)

        version = "1.0"
        characterEncoding = "UTF-8"
        isStandalone = true
        
    }

    init?(path: URL, options mask: XMLNode.Options = [] ) {

        guard let parser = XMLParser(contentsOf: path) else {
            return nil
        }

        fileName = path.lastPathComponent

        super.init()
        addChild(root)

        parser.delegate = self

        guard parser.parse() else {
            return nil
        }

        version = "1.0"
        characterEncoding = "UTF-8"
        isStandalone = true

    }

    func relationships(of type: String) -> [Relationship] {
        return root.children?.flatMap({ $0 as? Relationship}).filter({ $0.attribute(forName: "Type")?.stringValue == type}) ?? []
    }

    func write(under parentDir: URL) throws {

        let subDir = parentDir.appendingPathComponent("_rels")
        try FileManager.default.createDirectory(at: subDir, withIntermediateDirectories: true, attributes: nil)
        let filePath = subDir.appendingPathComponent(fileName)

        try xmlData.write(to: filePath)
    }

    func add(file: RelationshipItem) {
        root.addChild(Relationship(id: file.id, type: file.type, target: file.target))
    }
}


extension Relationships: XMLParserDelegate {

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        if elementName == "Relationships" {
            for (key,value) in attributeDict {
                root.addAttribute(name: key, value: value)
            }
        } else if elementName == "Relationship" {
            root.addChild(Relationship(attributes: attributeDict))
        } else {
            print("Unknown element: \(elementName)!")
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {

    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {

    }

    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {

    }
}

