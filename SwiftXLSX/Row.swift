//
//  Row.swift
//  SwiftXLS
//
//  Created by Carl Wieland on 4/28/17.
//  Copyright © 2017 Datum. All rights reserved.
//

import Foundation

public protocol XLSXExpressible {

}

extension String: XLSXExpressible {}
extension Int: XLSXExpressible {}
extension Double: XLSXExpressible {}
extension Float: XLSXExpressible {}



public class Row: XMLElement {

    let id: Int

    let sharedStrings: SharedStrings

    internal init(id: Int, sharedStrings: SharedStrings) {
        self.id = id
        self.sharedStrings = sharedStrings

        super.init(name: "row", uri: nil)

        addAttribute(name: "r", value: "\(id + 1)")
    }

    public func addColumn(_ attributes: [String: String]) {
        
        let cell = Cell(row: id, attributes: attributes)
        addChild(cell)
    }

    public var rawData: [XLSXExpressible?] {
        guard let cells = children as? [Cell] else {
            return []
        }

        let maxCol = cells.reduce(0, { max($0, $1.column)})

        var row = [XLSXExpressible?](repeating: nil, count: maxCol)
        for cell in cells {
            switch cell.value {
            case .double(let dbl):
                row[cell.column] = dbl
            case .integer(let int):
                row[cell.column] = int
            case .text(string: let sharedStrings, index: let index):
                row[cell.column] = sharedStrings.string(at: index)
            case .float( let flt):
                row[cell.column] = flt
            }

        }

        return row
    }

    public var maxColumnCount: Int {
        guard let cells = children as? [Cell] else {
            return 0
        }

        return cells.reduce(0, { max($0, $1.column)})
    }

    public func rowData(paddedTo width: Int) -> [XLSXExpressible?] {

        guard let cells = children as? [Cell] else {
            return []
        }

        var row = [XLSXExpressible?](repeating: nil, count: width)

        for cell in cells {
            let column = cell.column - 1
            print("Col:\(column)")
            assert(column >= 0)
            switch cell.value {
            case .double(let dbl):
                row[column] = dbl
            case .integer(let int):
                row[column] = int
            case .text(string: let sharedStrings, index: let index):
                row[column] = sharedStrings.string(at: index)
            case .float( let flt):
                row[column] = flt
            }
        }

        return row
    }

    /// Will set column data from 0..<data.count to be the value in the array
    ///
    /// - Parameter data: values for columns 0..<data.count
    public func setColumnData(_ data: [XLSXExpressible]) {
        if childCount == 0 {
            for (column, value) in data.enumerated() {

                let xlsxValue: XLSValue
                switch value {
                case let x as Int:
                    xlsxValue = .integer(x)
                case let x as Double:
                    xlsxValue = .double(x)
                case let x as String:
                    let index = sharedStrings.add(x)
                    xlsxValue = .text(string: sharedStrings, index: index)
                case let x as Float:
                    xlsxValue = .float(x)
                default:
                    fatalError("Unknown XLSXExpressible!")
                }

                let cell = Cell(row: id, column: column, value: xlsxValue)
                addChild(cell)
            }

        } else {
            fatalError("Not implemented!")
        }
    }
}
