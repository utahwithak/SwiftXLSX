//
//  SharedStrings.swift
//  SwiftXLSX
//
//  Created by Carl Wieland on 4/28/17.
//  Copyright © 2017 Datum. All rights reserved.
//

import Foundation

class SharedStrings {
    private static let controlChars = CharacterSet.controlCharacters

    private var sharedStrings = [String]()

    private var count = 0

    private var writeStream: FileHandle?

    init() {

    }

    init(from document: XMLDocument) throws {
        guard let sst = document.children?.first(where: {$0.name == "sst"}) as? XMLElement else {
            print("No SST!")
            return
        }

        if let countVal = sst.attribute(forName: "count")?.stringValue, let count = Int(countVal) {
            sharedStrings.reserveCapacity( count)
        }

        guard let strings = sst.children?.flatMap({ ($0 as? XMLElement)?.children?.first }) as? [XMLElement] else {
            return
        }
        
        sharedStrings = strings.flatMap( { $0.stringValue })
        guard strings.count == sharedStrings.count else {
            throw SwiftXLSX.missingContent("Shared strings missing!")
        }

    }

    func add(_ value: String) -> Int {
        let index = count
        let cleaned: String
        if value.rangeOfCharacter(from: SharedStrings.controlChars) != nil {
            var temp = value
            while let range = temp.rangeOfCharacter(from: SharedStrings.controlChars) {
                temp.removeSubrange(range)
            }
            cleaned = temp
        } else {
            cleaned = value
        }

        if let writeStream = writeStream, let data = "<si><t>\(cleaned)</t></si>".data(using: .utf8) {
            writeStream.write(data)
        } else {
            print("FAILED TO WRITE OUT SHARED STRING!")
        }

        count += 1
        return index
    }

    func string(at index: Int) -> String? {
        guard index < sharedStrings.count else {
            return nil
        }

        return sharedStrings[index]
    }


    func prepareForWriting(under parentDir: URL) throws {
        let path = parentDir.appendingPathComponent("sharedStrings.xml")
        FileManager.default.createFile(atPath: path.path, contents: nil, attributes: nil)
        writeStream = try FileHandle(forUpdating: path)
        try writeStream?.write(string: "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?><sst xmlns=\"http://schemas.openxmlformats.org/spreadsheetml/2006/main\">")
    }

    func finishWriting() {
        try? writeStream?.write(string: "</sst>")
        writeStream?.closeFile()
        writeStream = nil
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
