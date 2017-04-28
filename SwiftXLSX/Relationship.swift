//
//  Relationship.swift
//  SwiftXLS
//
//  Created by Carl Wieland on 4/28/17.
//  Copyright © 2017 Datum. All rights reserved.
//

import Foundation

class Relationship: XMLAttributeItem {

    init(id: String, type: String, target: String) {
        super.init(name: "Relationship")
        attributes["Id"] = .text(id)
        attributes["Type"] = .text(type)
        attributes["Target"] = .text(target)
    }

}
