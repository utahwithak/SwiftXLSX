//
//  XMLElement.swift
//  SwiftXLS
//
//  Created by Carl Wieland on 4/27/17.
//  Copyright © 2017 Datum. All rights reserved.
//

import Foundation

class SimpleElement: XMLElement {
    init(name: String, value: String) {
        super.init(name: name.validXMLString, uri: nil)
        stringValue = value.validXMLString
    }
}
