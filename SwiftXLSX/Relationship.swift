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
        addAttribute(name: "Id", value: id)
        addAttribute(name: "Type", value: type)
        addAttribute(name: "Target", value: target)
    }

}
