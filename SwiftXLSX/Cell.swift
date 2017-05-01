//
//  Cell.swift
//  SwiftXLS
//
//  Created by Carl Wieland on 4/28/17.
//  Copyright © 2017 Datum. All rights reserved.
//

import Foundation

public enum XLSValue: XMLWritable, Equatable {
    case integer(Int)
    case text(String)
    case double(Double)
    case float(Float)

    func write(to handle: FileHandle) throws {
        try handle.write(string: "<v>")
        switch self {
        case .integer(let x):
            try handle.write(string: "\(x)")
        case .double(let x):
            try handle.write(string: "\(x)")
        case .float(let x):
            try handle.write(string: "\(x)")

        case .text(let str):
            try str.write(to: handle)
        }
        try handle.write(string: "</v>")
    }
}
public func ==(lhs: XLSValue, rhs: XLSValue) -> Bool {
    switch (lhs, rhs) {
    case (.integer(let x), .integer(let y)):
        return x == y
    case (.double(let x), .double(let y)):
        return x == y
    case (.float(let x), .float(let y)):
        return x == y
    case (.text(let x), .text(let y)):
        return x == y
    default:
        return false

    }
}

public class Cell: XMLElement {

    private static let validColumnLetters = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]

    static func colToString(_ column: Int) -> String {

        var id = ""
        var index = column
        while index > 0 {
            let modulo = (index - 1) % 26;
            id = "\(validColumnLetters[modulo])\(id)"
            index = (index - modulo) / 26
        }
        
        return id;
    }

    let row: Int

    let column: Int

    var sharedStringIndex: Int?

    var value: XLSValue

    init(row: Int, column: Int, value: XLSValue) {
        self.row = row
        self.column = column
        self.value = value
    }

    lazy var identifier: String = {
        return "\(Cell.colToString(self.column + 1))\(self.row + 1)"
    }()

    override var elementName: String {
        return "c"
    }

    override func writeheaderAttributes(to handle: FileHandle) throws {
        try handle.write(string: " r=\"\(identifier)\"")
        if sharedStringIndex != nil {
            try handle.write(string: " t=\"s\"")
        }
    }
    
    override func writeElements(to handle: FileHandle) throws {
        if let index = sharedStringIndex {
            let indexVal = XLSValue.integer(index)
            try indexVal.write(to: handle)
        } else {
            try value.write(to: handle)
        }
    }


    func prepareForWriting(with sharedStrings: SharedStrings) {
        if case .text(let text) = value {
            sharedStringIndex = sharedStrings.add(text)
        }
    }
}
