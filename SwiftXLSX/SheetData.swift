//
//  SheetData.swift
//  SwiftXLS
//
//  Created by Carl Wieland on 4/28/17.
//  Copyright © 2017 Datum. All rights reserved.
//

import Foundation

class SheetData: XMLElement {
    
    let sharedStrings: SharedStrings
    
    init(sharedStrings: SharedStrings) {
        self.sharedStrings = sharedStrings
        super.init(name: "sheetData", uri: nil)
    }

    private var maxRow = 0

    private var currentRow: Row?

    func newRow() -> Row {
        let newRow = Row(id: maxRow, sharedStrings: sharedStrings)
        maxRow += 1
        currentRow = newRow
        addChild(newRow)
        return newRow
    }
    
}

extension SheetData: XMLParserDelegate {

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "row" {
            guard let rStr = attributeDict["r"], let id = Int(rStr) else {
                fatalError("No row ID!")
            }
            maxRow = max(id, maxRow)
            let newRow = Row(id: id - 1, sharedStrings: sharedStrings)
            addChild(newRow)
            currentRow = newRow
        } else if elementName == "c" {
            guard let curRow = currentRow else {
                fatalError("missing row!")
            }

            curRow.addColumn(attributeDict)
        }

    }
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "row" {
            currentRow = nil
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard let curRow = currentRow else {
            return
        }

        guard let lastAddedCell = curRow.children?.last as? Cell else {
            return
        }

        if lastAddedCell.attribute(forName: "t")?.stringValue == "s", let index = Int(string) {
            lastAddedCell.value = .text(string: sharedStrings, index: index)
        } else if let intVal = Int(string)  {
            lastAddedCell.value = .integer(intVal)
        } else if let doubVal = Double(string) {
            lastAddedCell.value = .double(doubVal)
        }

    }

}
