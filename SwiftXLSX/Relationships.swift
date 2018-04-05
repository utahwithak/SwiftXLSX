//
//  Relationships.swift
//  SwiftXLS
//
//  Created by Carl Wieland on 4/28/17.
//  Copyright © 2017 Datum. All rights reserved.
//

import Foundation
class Relationship {
    let id: String
    let type: String
    let target: String

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

    func write(to handle: FileHandle) throws {
        try handle.write(string: "<Relationship Id=\"\(id)\" Type=\"\(type)\" Target=\"\(target)\"></Relationship>")
    }

    var xmlElement: XMLElement {
        let element = XMLElement(name: "Relationship")
        return element
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

        relationships = rawRels.compactMap { Relationship(from: $0) }

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

        let subDir = parentDir.appendingPathComponent("_rels")
        try FileManager.default.createDirectory(at: subDir, withIntermediateDirectories: true, attributes: nil)

        let filePath = subDir.appendingPathComponent(fileName)

        FileManager.default.createFile(atPath: filePath.path, contents: nil, attributes: nil)
        let writeStream = try FileHandle(forWritingTo: filePath)
        try writeStream.write(string: "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?><Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\">")

        for relationship in relationships {
            try relationship.write(to: writeStream)
        }

        try writeStream.write(string: "</Relationships>")
        writeStream.closeFile()

    }

    func add(file: RelationshipItem) {
        relationships.append(Relationship(id: file.id, type: file.type, target: file.target))
    }

    func add(type: String, target: String) -> Relationship {
        let created = Relationship(id: "rId\(relationships.count + 1)", type: type, target: target)
        relationships.append(created)
        return created
    }
}
