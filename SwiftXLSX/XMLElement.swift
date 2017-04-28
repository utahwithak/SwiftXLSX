//
//  XMLElement.swift
//  SwiftXLS
//
//  Created by Carl Wieland on 4/27/17.
//  Copyright © 2017 Datum. All rights reserved.
//

import Foundation

public class XMLElement: XMLWritable {


    var elementName: String {
        fatalError("Must override in subclass!")
    }

    func writeheaderAttributes(to handle: FileHandle) throws {
        /* no op */
    }

    func writeElements(to handle: FileHandle) throws {
        /* no op */
    }

    func write(to handle: FileHandle) throws {
        try handle.write(string: "<\(elementName) ")
        if isEmpty {
            try handle.write(string: "/>")
            return
        }
        try writeheaderAttributes(to: handle)
        try handle.write(string: ">")
        try writeElements(to: handle)
        try handle.write(string: "</\(elementName)>")

    }

    var isEmpty: Bool {
        return false
    }

}
