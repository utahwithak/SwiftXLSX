//
//  ContentTypes.swift
//  SwiftXLS
//
//  Created by Carl Wieland on 4/27/17.
//  Copyright © 2017 Datum. All rights reserved.
//

import Foundation

fileprivate protocol ContentType: class {
    var name: String { get }
    var attributes: [String: String] { get }
}

protocol DocumentContentItem {
    var contentType: String { get }
    var partName: String { get }
}


fileprivate class OverrideType: ContentType {
    let name = "Override"
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
}

fileprivate class DefaultType: ContentType {
    let name = "Default"
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

}


class ContentTypes {

    private var types: [ContentType]

    init() {
        types = [ContentType]()
        types.append(DefaultType(type: "application/xml", fileExtension: "xml"))
        types.append(DefaultType(type: "application/vnd.openxmlformats-package.relationships+xml", fileExtension: "rels"))
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

        if FileManager.default.fileExists(atPath: path.path) {
            try FileManager.default.removeItem(at: path)
        }
//
//        try xmlData.write(to: path)

    }
}
