//
//  Cell.swift
//  SwiftXLS
//
//  Created by Carl Wieland on 4/28/17.
//  Copyright © 2017 Datum. All rights reserved.
//

import Foundation

enum XLSValue: XMLWritable {
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

class Cell: XMLElement {

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

    var value: XLSValue

    init(row: Int, column: Int, value: XLSValue) {
        self.row = row
        self.column = column
        self.value = value
    }

    lazy var identifier: String = {
        return "\(Cell.colToString(self.column))\(self.row)"
    }()

    override var elementName: String {
        return "c"
    }

    override func writeElements(to handle: FileHandle) throws {
        try value.write(to: handle)
    }

}
