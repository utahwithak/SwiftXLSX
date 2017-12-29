//
//  Row.swift
//  SwiftXLS
//
//  Created by Carl Wieland on 4/28/17.
//  Copyright © 2017 Datum. All rights reserved.
//

import Foundation

public protocol XLSXExpressible { }
extension String: XLSXExpressible {}
extension Int: XLSXExpressible {}
extension Double: XLSXExpressible {}
extension Float: XLSXExpressible {}


public class Row {

    let id: Int

    private var cells = [Cell]()

    internal init(id: Int) {
        self.id = id
//
//        super.init(name: "row", uri: nil)
//
//        addAttribute(name: "r", value: "\(id + 1)")
    }
    internal init(from element: XMLElement, strings: SharedStrings) throws {
        guard let idStr = element.attribute(forName: "r")?.stringValue, let id = Int(idStr) else {
            throw SwiftXLSX.missingContent("Missing Row Id")
        }

        self.id = id

        if let rawColumns = element.children as? [XMLElement] {
            cells = try rawColumns.map { return try Cell(row: id, element: $0, strings: strings) }
        }

        
    }

    public var rawData: [XLSXExpressible?] {

        let maxCol = cells.reduce(0, { max($0, $1.column)})

        var row = [XLSXExpressible?](repeating: nil, count: maxCol)
        for cell in cells {
            switch cell.value {
            case .double(let dbl):
                row[cell.column] = dbl
            case .integer(let int):
                row[cell.column] = int
            case .text(let text):
                row[cell.column] = text
            case .float( let flt):
                row[cell.column] = flt
            }

        }

        return row
    }

    public var maxColumnCount: Int {
        return cells.reduce(0, { max($0, $1.column)})
    }

    public func rowData(paddedTo width: Int) -> [XLSXExpressible?] {

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
            case .text(let text):
                row[column] = text
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
        cells.removeAll(keepingCapacity: true)
        for (column, value) in data.enumerated() {

            let xlsxValue: XLSValue
            switch value {
            case let x as Int:
                xlsxValue = .integer(x)
            case let x as Double:
                xlsxValue = .double(x)
            case let x as String:
                xlsxValue = .text(x)
            case let x as Float:
                xlsxValue = .float(x)
            default:
                fatalError("Unknown XLSXExpressible!")
            }
            let cell = Cell(row: id, column: column, value: xlsxValue)
            cells.append(cell)

        }


    }
}
