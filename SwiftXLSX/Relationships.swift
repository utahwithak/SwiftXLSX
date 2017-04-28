//
//  Relationships.swift
//  SwiftXLS
//
//  Created by Carl Wieland on 4/28/17.
//  Copyright © 2017 Datum. All rights reserved.
//

import Foundation

class Relationships: XMLElement {

    override var elementName: String {
        return "Relationships"
    }

    var relationships = [Relationship]()

    let name: String

    init(name: String) {
        self.name = name
    }

    func write(under parentDir: URL) throws {

        let subDir = parentDir.appendingPathComponent("_rels")
        try FileManager.default.createDirectory(at: subDir, withIntermediateDirectories: true, attributes: nil)
        let filePath = subDir.appendingPathComponent(name)
        guard FileManager.default.createFile(atPath: filePath.path, contents: nil, attributes: nil) else {
            throw NSError(domain: "com.datum.SwiftXLS", code: 6, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Unable to Create file", comment: "Create file error")])
        }
        let fileHandle = try FileHandle(forWritingTo: filePath)
        try fileHandle.writeXMLHeader()
        try write(to: fileHandle)

    }

    func add(file: RelationshipItem) {
        relationships.append(Relationship(id: file.id, type: file.type, target: file.target))
    }

    override func writeheaderAttributes(to handle: FileHandle) throws {
        try handle.write(string: "xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\"")
    }

    override func writeElements(to handle: FileHandle) throws {
        for relation in relationships {
            try relation.write(to: handle)
        }
    }
}
