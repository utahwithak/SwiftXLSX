//
//  SheetData.swift
//  SwiftXLS
//
//  Created by Carl Wieland on 4/28/17.
//  Copyright © 2017 Datum. All rights reserved.
//

import Foundation

class SheetData: XMLElement {

    var rows = [Row]()

    override var isEmpty: Bool {
        return rows.isEmpty
    }
    
    override var elementName: String {
        return "sheetData"
    }
}
