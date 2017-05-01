//
//  XMLAttributeItem.swift
//  SwiftXLS
//
//  Created by Carl Wieland on 4/27/17.
//  Copyright © 2017 Datum. All rights reserved.
//

import Cocoa

class XMLAttribute: XMLNode {

    init(key: String, value: String) {
        super.init(kind: .attribute, options: [])
        name = key.validXMLString
        stringValue = value.validXMLString
    }

    convenience init(name: String, value: String) {
        self.init(key: name, value: value)
    }
    
}

