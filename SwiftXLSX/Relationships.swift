//
//  Relationships.swift
//  SwiftXLS
//
//  Created by Carl Wieland on 4/28/17.
//  Copyright © 2017 Datum. All rights reserved.
//

import Foundation
class Relationship {
    let name = "Relationship"
    let id: String
    let type: String
    let target: String

    var attributes: [String: String] {
        return ["Id": id, "Type": type, "Target": target]
    }

    init(id: String, type: String, target: String) {
        self.id = id
        self.type = type
        self.target = target
    }

    convenience init?(from element: XMLElement) {
        guard let id = element.attribute(forName: "Id")?.stringValue, let type = element.attribute(forName: "Type")?.stringValue, let target = element.attribute(forName: "Target")?.stringValue else {
            return nil
        }
        self.init(id: id, type: type, target: target)

    }
}

class Relationships {

    private var relationships: [Relationship]

    init() {
        relationships = [Relationship]()
    }

    init(from document: XMLDocument) throws {

        guard let root = document.children?.first( where: {$0.name == "Relationships" }), let rawRels = root.children as? [XMLElement], !rawRels.isEmpty else {
            throw SwiftXLSX.missingContent("Relationships")
        }
        
        relationships = rawRels.flatMap { Relationship(from: $0) }

        guard relationships.count == rawRels.count else {
            throw SwiftXLSX.missingContent("Relationship count doesn't match")
        }

    }


    func relationships(matching type: String) -> [Relationship] {
        return relationships.filter({ $0.type == type})
    }

    func target(for id: String) -> String? {
        return relationships.first(where: { $0.id == id})?.target
    }

    func write(under parentDir: URL, fileName: String) throws {
//
//        let subDir = parentDir.appendingPathComponent("_rels")
//        try FileManager.default.createDirectory(at: subDir, withIntermediateDirectories: true, attributes: nil)
//        let filePath = subDir.appendingPathComponent(fileName)
//
////        try xmlData.write(to: filePath)
    }

    func add(file: RelationshipItem) {
//        rootElement()?.addChild(Relationship(id: file.id, type: file.type, target: file.target))
    }

    func add(type: String, target: String) -> Relationship {
        let created = Relationship(id: "rId\(relationships.count + 1)", type: type, target: target)
        relationships.append(created)
        return created
    }
}

//
//extension Relationships: XMLParserDelegate {
//
//    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
//        if elementName == "Relationships" {
//            for (key,value) in attributeDict {
//                root.addAttribute(name: key, value: value)
//            }
//        } else if elementName == "Relationship" {
//            root.addChild(Relationship(attributes: attributeDict))
//        } else {
//            print("Unknown element: \(elementName)!")
//        }
//    }
//
//    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
//
//    }
//
//    func parser(_ parser: XMLParser, foundCharacters string: String) {
//
//    }
//
//    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
//
//    }
//}

