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

    private static let validColumnLetters = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]

    private static let columnChars: [Character] = Cell.validColumnLetters.map({ $0.first! })

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

    static func identifierToCol(_ ident: String) -> Int {
        let nums = ident.uppercased().flatMap({ columnChars.index(of: $0 )})

        var sum = 0
        for val in nums {
            sum *= 26
            sum += (val + 1)
        }

        return sum

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

    init(row: Int, element: XMLElement, strings: SharedStrings) throws {
        self.row = row

        guard let identifier = element.attribute(forName: "r")?.stringValue, let cellValue = element.children?.first else {
            throw SwiftXLSX.missingContent("Missing column identifier OR child")
        }

        column = Cell.identifierToCol(identifier)

        guard let stringVal = cellValue.stringValue else {
            throw SwiftXLSX.missingContent("Missing cell content!")
        }

        if let type = element.attribute(forName: "t")?.stringValue, type == "s" {
            guard let index = Int(stringVal), let text = strings.string(at: index) else {
                throw SwiftXLSX.missingContent("Missing Index")
            }
            value = .text(text)
        } else if let doubVal = Double(stringVal) {
            value = .double(doubVal)
        } else if let floatVal = Float(stringVal) {
            value = .float(floatVal)
        } else if let intVal = Int(stringVal) {
            value = .integer(intVal)
        } else {
            throw SwiftXLSX.missingContent("Invalid content type!")
        }

    }

    lazy var identifier: String = {
        return "\(Cell.colToString(self.column + 1))\(self.row + 1)"
    }()

}
