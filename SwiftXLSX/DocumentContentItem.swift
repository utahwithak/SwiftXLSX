//
//  DocumentContentItem.swift
//  SwiftXLS
//
//  Created by Carl Wieland on 4/28/17.
//  Copyright © 2017 Datum. All rights reserved.
//

import Foundation

protocol DocumentContentItem {
    var contentType: String { get }
    var partName: String { get }
}
