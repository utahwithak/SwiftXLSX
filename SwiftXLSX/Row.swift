//
//  Row.swift
//  SwiftXLS
//
//  Created by Carl Wieland on 4/28/17.
//  Copyright © 2017 Datum. All rights reserved.
//

import Foundation

public class Row: XMLElement {

    let id: Int

    var cells = [Cell]()

    let sharedStrings: SharedStrings

    internal init(id: Int, sharedStrings: SharedStrings) {
        self.id = id
        self.sharedStrings = sharedStrings
        super.init()
    }

    override var elementName: String {
        return "row"
    }

    override var isEmpty: Bool {
        return cells.isEmpty
    }

    override func writeheaderAttributes(to handle: FileHandle) throws {
        try handle.write(string: " r=\"\(id + 1)\"")
    }

    public func set(column: Int, to newValue: XLSValue, create: Bool = false) {

        if let cell = cells.filter({$0.column == column}).first {
            cell.value = newValue

        } else if create {
            let newCell = Cell(row: id, column: column, value: newValue)
            cells.append(newCell)
        } else {
            print("Failed to find cell for column: \(column) and didn't create one!")
        }
    }

    /// Will set column data from 0..<data.count to be the value in the array
    ///
    /// - Parameter data: values for columns 0..<data.count
    public func setColumnData(_ data: [XLSValue]) {
        if cells.isEmpty {
            cells = data.enumerated().map { (column, value) in
                return Cell(row: id, column: column, value: value)
            }

        } else {
            for (index, value) in data.enumerated() {
                set(column: index, to: value, create: true)
            }
        }
    }

    /// Removes all cells that are text based and empty
    ///
    public func clearEmptyCells() {
        cells = cells.filter({
            if case .text(let strVal) = $0.value {
                return !strVal.isEmpty
            }
            return true
        })
    }

    override func writeElements(to handle: FileHandle) throws {
        cells.sort(by: {
            return $0.column < $1.column
        })

        for cell in cells {
            cell.prepareForWriting(with: sharedStrings)
            try cell.write(to: handle)
        }

    }

    /// Get the Cell for that index's column
    ///
    /// - Parameter index: column to get
    subscript (index: Int) -> Cell {
        set {
            precondition(index >= 0)

            if let cell = cells.filter({$0.column == index}).first {
                cell.value = newValue.value
            } else {
                let newCell = Cell(row: id, column: index, value: newValue.value)
                cells.append(newCell)
            }
        }
        get {
            precondition(index >= 0)

            if let cell = cells.filter({$0.column == index}).first {
                return cell

            } else {
                let newCell = Cell(row: id, column: index, value: .text(""))
                cells.append(newCell)
                return newCell
                
            }

        }
    }

}
