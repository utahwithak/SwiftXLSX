//
//  ContentTypes.swift
//  SwiftXLS
//
//  Created by Carl Wieland on 4/27/17.
//  Copyright © 2017 Datum. All rights reserved.
//

import Foundation

fileprivate protocol ContentType: class {
    func writeTo(handle stream: FileHandle) throws
}

protocol DocumentContentItem {
    var contentType: String { get }
    var partName: String { get }
}

fileprivate class OverrideType: ContentType {
    let contentType: String
    let partName: String

    var attributes: [String : String] {
        return ["ContentType":contentType, "PartName": partName]
    }

    init(type: String, part: String) {
        contentType = type
        partName = part

    }

    convenience init?(node: XMLElement) {
        guard let type = node.attribute(forName: "ContentType")?.stringValue, let part = node.attribute(forName: "PartName")?.stringValue else {
            return nil
        }
        self.init(type: type, part: part)
    }

    func writeTo(handle stream: FileHandle) throws {
        try stream.write(string: "<Override ContentType=\"\(contentType)\" PartName=\"\(partName)\"></Override>")
    }

}

fileprivate class DefaultType: ContentType {
    let contentType: String
    let ext: String

    var attributes: [String : String] {
        return ["ContentType": contentType, "Extension": ext]
    }

    init(type: String, fileExtension: String) {
        contentType = type
        ext = fileExtension
    }

    convenience init?(node: XMLElement) {

        guard let type = node.attribute(forName: "ContentType")?.stringValue, let part = node.attribute(forName: "Extension")?.stringValue else {
            return nil
        }

        self.init(type: type, fileExtension: part)
    }

    func writeTo(handle stream: FileHandle) throws {
        try stream.write(string: "<Default ContentType=\"\(contentType)\" Extension=\"\(ext)\"></Default>")
    }

}


class ContentTypes {

    private var types: [ContentType]

    init() {
        types = [ContentType]()
        types.append(DefaultType(type: "application/xml", fileExtension: "xml"))
        types.append(DefaultType(type: "application/vnd.openxmlformats-package.relationships+xml", fileExtension: "rels"))
        types.append(DefaultType(type: "image/jpeg", fileExtension: "jpeg"))

    }

    init(from document: XMLDocument) throws {
        guard let typeNode = document.children?.first(where: {$0.name == "Types"}), let rawTypes = typeNode.children, !rawTypes.isEmpty else {
            throw SwiftXLSX.missingContent("Missing 'Type' child in ContentTypes")
        }

        types = rawTypes.flatMap {
            guard let element = $0 as? XMLElement, let name = element.name else {
                return nil
            }

            switch name {
            case "Default":
                return DefaultType(node: element)
            case "Override":
                return OverrideType(node: element)
            default:
                return nil
            }
        }
        if types.count != rawTypes.count {
            throw SwiftXLSX.missingContent("Type count doesn't match")

        }

    }

    func add(document: DocumentContentItem) {
        types.append(OverrideType(type: document.contentType, part: document.partName))
    }

    func write(under parentDir: URL) throws {

        let path = parentDir.appendingPathComponent("[Content_Types].xml")

        FileManager.default.createFile(atPath: path.path, contents: nil, attributes: nil)
        let writeStream = try FileHandle(forUpdating: path)
        try writeStream.write(string: "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?><Types xmlns=\"http://schemas.openxmlformats.org/package/2006/content-types\">")
        for type in types {
            try type.writeTo(handle: writeStream)
        }
        
        try writeStream.write(string: "</Types>")
        writeStream.closeFile()

    }
}
