//
//  Workbook.swift
//  SwiftXLS
//
//  Created by Carl Wieland on 4/18/17.
//  Copyright © 2017 Datum. All rights reserved.
//

import Foundation
import Compression

enum SwiftXLSX: Error {
    case failedToCreateArchive
    case archiveMissingFile
    case missingContent(String)
}

public class XLSXDocument {

    let contentTypes: ContentTypes

    let relationships: Relationships

    let workbook: Workbook

    public init() {
        contentTypes = ContentTypes()
        relationships = Relationships()
        workbook = Workbook(in: relationships)

        contentTypes.add(document: workbook)
    }

    public init(path: URL) throws {

        guard let archive = Archive(url: path, accessMode: .read) else  {
            throw SwiftXLSX.failedToCreateArchive
        }

        guard let contentTypesArchive = archive["[Content_Types].xml"], let relationshipArchive = archive["_rels/.rels"] else {
            throw SwiftXLSX.archiveMissingFile
        }

        let contentDoc = try archive.extractAll(of: contentTypesArchive) { try XMLDocument(data: $0) }
        let relDoc = try archive.extractAll(of: relationshipArchive, handler: { try XMLDocument(data: $0 )})

        self.contentTypes = try ContentTypes(from: contentDoc)
        self.relationships = try Relationships(from: relDoc)

        guard let workbookRelationship = relationships.relationships(matching: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument").first else {
            throw SwiftXLSX.missingContent("Workbook Relationship")
        }

        workbook = try Workbook(from: workbookRelationship, in: archive)

    }

    public func addSheet(named name: String) -> Sheet {
        return workbook.createSheet(named: name)
    }

    public var sheets: [Sheet] {
        return workbook.sheets
    }

    public func save(to path: URL) throws {

        let tempDirURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(NSUUID().uuidString)

        defer {
            do {
                try FileManager.default.removeItem(at: tempDirURL)
            } catch {
                print("Failed to clean up \(error)")
            }
        }
        let fileManager = FileManager.default
        try fileManager.createDirectory(at: tempDirURL, withIntermediateDirectories: true, attributes: nil)

        try workbook.write(under: tempDirURL, contents: contentTypes)

        try contentTypes.write(under: tempDirURL)
        try relationships.write(under: tempDirURL, fileName: ".rels")

        try fileManager.zipItem(at: tempDirURL, to: path, shouldKeepParent: false)

    }

}

