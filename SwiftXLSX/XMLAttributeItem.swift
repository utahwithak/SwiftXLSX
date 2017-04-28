//
//  XMLAttributeItem.swift
//  SwiftXLS
//
//  Created by Carl Wieland on 4/27/17.
//  Copyright © 2017 Datum. All rights reserved.
//

import Foundation
enum XMLAttributeValue: XMLWritable {
    case text(String)

    func write(to handle: FileHandle) throws {
        switch self {
        case .text(let strVal):
            try handle.write(string: "\"")
            try strVal.write(to: handle)
            try handle.write(string: "\"")
        }
    }
}

class XMLAttributeItem: XMLWritable {

    var attributes = [String: XMLAttributeValue]()

    let name: String
    init(name: String) {
        self.name = name
    }

    func add(value: XMLAttributeValue, for key: String) {
        attributes[key] = value
    }

    func write(to handle: FileHandle) throws {
        try handle.write(string: "<\(name)")
        for (name,attribute) in attributes {
            try handle.write(string: " \(name)=")
            try attribute.write(to: handle)
        }
        try handle.write(string: "/>")
    }
}
