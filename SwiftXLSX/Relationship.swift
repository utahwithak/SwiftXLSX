//
//  Relationship.swift
//  SwiftXLS
//
//  Created by Carl Wieland on 4/28/17.
//  Copyright © 2017 Datum. All rights reserved.
//

import Foundation

class Relationship: XMLElement {

    init(id: String, type: String, target: String) {
        super.init(name: "Relationship", uri: nil)
        addAttribute(XMLAttribute(key: "Id", value: id))
        addAttribute(XMLAttribute(key: "Type", value: type))
        addAttribute(XMLAttribute(key: "Target", value: target))
    }

}
