//
//  Row.swift
//  SwiftXLS
//
//  Created by Carl Wieland on 4/28/17.
//  Copyright © 2017 Datum. All rights reserved.
//

import Foundation

class Row: XMLElement {

    let id: Int

    init(id: Int) {
        self.id = id
        super.init()
    }

    var cells = [Cell]()

    override var elementName: String {
        return "row"
    }

    override var isEmpty: Bool {
        return cells.isEmpty
    }
}
