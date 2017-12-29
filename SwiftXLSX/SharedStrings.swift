//
//  SharedStrings.swift
//  SwiftXLSX
//
//  Created by Carl Wieland on 4/28/17.
//  Copyright © 2017 Datum. All rights reserved.
//

import Foundation

class SharedStrings {

    private var sharedStrings = [String]()

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

        if let index = sharedStrings.index(of: value) {
            return index
        }

        sharedStrings.append(value)

        return sharedStrings.count - 1
    }

    func string(at index: Int) -> String? {
        guard index < sharedStrings.count else {
            return nil
        }

        return sharedStrings[index]
    }



    func write(under parentDir: URL) throws {
//        let path = parentDir.appendingPathComponent("sharedStrings.xml")
//
//        if FileManager.default.fileExists(atPath: path.path) {
//            try FileManager.default.removeItem(at: path)
//        }
//
//        let data = xmlData
//        try data.write(to: path)
    }

}

//extension SharedStrings: DocumentContentItem {
//    
//    var contentType: String {
//        return "application/vnd.openxmlformats-officedocument.spreadsheetml.sharedStrings+xml"
//    }
//    var partName: String {
//        return "/xl/sharedStrings.xml"
//    }
//}

//extension SharedStrings: RelationshipItem {
//
//    var target: String {
//        return "sharedStrings.xml"
//    }
//
//    var type: String {
//        return "http://schemas.openxmlformats.org/officeDocument/2006/relationships/sharedStrings"
//    }
//}

//fileprivate class SharedString {
//    private static let controlChars = CharacterSet.controlCharacters
//    init(text: String) {
//        self.text = text
//    }
//
//    let text: String
////        get {
////            return elements(forName: "t").first?.stringValue ?? ""
////        }
////        set {
////            while childCount > 0 {
////                removeChild(at: 0)
////            }
////            let cleaned: String
////            if newValue.rangeOfCharacter(from: SharedString.controlChars) != nil {
////                var temp = newValue
////                while let range = temp.rangeOfCharacter(from: SharedString.controlChars) {
////                    temp.removeSubrange(range)
////                }
////                cleaned = temp
////            } else {
////                cleaned = newValue
////            }
////            addChild(XMLElement(name: "t", stringValue: cleaned))
////        }
////
////    }
//
//}

