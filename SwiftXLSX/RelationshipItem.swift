//
//  RelationshipItem.swift
//  SwiftXLS
//
//  Created by Carl Wieland on 4/28/17.
//  Copyright © 2017 Datum. All rights reserved.
//

import Foundation

protocol RelationshipItem {
    var id: String { get }
    var type: String { get }
    var target: String { get }
}
