//
//  Cell.swift
//  SwiftXLS
//
//  Created by Carl Wieland on 4/28/17.
//  Copyright © 2017 Datum. All rights reserved.
//

import Foundation

internal enum XLSValue {
    case integer(Int)
    case text(String)
    case double(Double)
    case float(Float)

}

internal class Cell {

    private static let validColumnLetters = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]

    static func colToString(_ column: Int) -> String {

        var id = ""
        var index = column
        while index > 0 {
            let modulo = (index - 1) % 26
            id = "\(validColumnLetters[modulo])\(id)"
            index = (index - modulo) / 26
        }

        return id
    }

    static func identifierToCol(_ ident: String) -> Int {

        var sum = 0
        for char in ident.utf8 {
            if char > 90 || char < 65 {
                return sum
            }
            sum *= 26
            sum += (Int(char) - 64)
        }

        return sum

    }

    let row: Int

    let column: Int

    var value: XLSValue

    init(row: Int, column: Int, value: XLSValue) {
        self.row = row
        self.column = column
        self.value = value
    }

    init(row: Int, element: XMLElement, strings: SharedStrings) throws {
        self.row = row

        guard let identifier = element.attribute(forName: "r")?.stringValue, let cellValue = element.children?.first?.stringValue else {
            throw SwiftXLSX.missingContent("Missing column identifier OR child")
        }

        column = Cell.identifierToCol(identifier)

        if let type = element.attribute(forName: "t")?.stringValue, type == "s" {
            guard let index = Int(cellValue), let text = strings.string(at: index) else {
                throw SwiftXLSX.missingContent("Missing Index")
            }
            value = .text(text)
        } else if let intVal = Int(cellValue) {
            value = .integer(intVal)
        } else if let doubVal = Double(cellValue) {
            value = .double(doubVal)
        } else if let floatVal = Float(cellValue) {
            value = .float(floatVal)
        } else {
            throw SwiftXLSX.missingContent("Invalid content type!")
        }

    }

    lazy var identifier: String = {
        return "\(Cell.colToString(self.column + 1))\(self.row + 1)"
    }()

    func write(to handle: FileHandle, with strings: SharedStrings) throws {
        var xml = "<c r=\"\(identifier)\""

        switch value {
        case .text(let strVal):
            let index = strings.add(strVal)
            xml += " t=\"s\"><v>\(index)</v></c>"
        case .double(let x):
            xml += "><v>\(x)</v></c>"
        case .integer(let x):
            xml += "><v>\(x)</v></c>"
        case .float(let x):
            xml += "><v>\(x)</v></c>"
        }
        try handle.write(string: xml)
    }
}
