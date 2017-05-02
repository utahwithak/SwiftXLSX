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
    case text(string: SharedStrings, index: Int)
    case double(Double)
    case float(Float)

    var xmlValue: String {
        switch self {
        case .integer(let x):
            return "\(x)"
        case .double(let x):
            return "\(x)"
        case .float(let x):
            return "\(x)"
        case .text(_ , let index):
            return "\(index)"
        }
    }
}

internal class Cell: XMLElement {

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

    var value: XLSValue {
        didSet {
            if case let .text(sharedStr, index) = oldValue {
                sharedStr.removeShared(at: index)
            }
            updateChildren()
        }
    }

    init(row: Int, column: Int, value: XLSValue) {
        self.row = row
        self.column = column
        self.value = value
        super.init(name: "c", uri: nil)

        addAttribute(name: "r", value: identifier)

        updateChildren()
    }

    func updateChildren() {
        let newElement = XMLElement(name:"v", stringValue: value.xmlValue)

        if childCount > 0 {
            replaceChild(at: 0, with: newElement)
        } else {
            addChild(newElement)
        }

        if case .text(_, _) = value {
            addAttribute(name: "t", value: "s")
        } else {
            removeAttribute(forName: "t")
        }
    
    }

    lazy var identifier: String = {
        return "\(Cell.colToString(self.column + 1))\(self.row + 1)"
    }()

}
