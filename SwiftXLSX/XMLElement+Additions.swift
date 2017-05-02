//
//  XMLElement+Additions.swift
//  SwiftXLSX
//
//  Created by Carl Wieland on 5/1/17.
//  Copyright © 2017 Datum. All rights reserved.
//

import Cocoa

extension XMLElement {
    func addAttribute(name: String, value: String) {
        let attribute = XMLElement(kind: .attribute)
        attribute.name = name
        attribute.stringValue = value
        addAttribute(attribute)
    }
}
