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
