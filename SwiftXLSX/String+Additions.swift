//
//  String+Additions.swift
//  SwiftXLSX
//
//  Created by Carl Wieland on 5/1/17.
//  Copyright © 2017 Datum. All rights reserved.
//

import Foundation

extension String {

    var validXMLString: String {
        var clean = replacingOccurrences(of: "&", with: "&amp;")
        clean = clean.replacingOccurrences(of: "<", with: "&lt;")
        clean = clean.replacingOccurrences(of: ">", with: "&gt;")
        clean = clean.replacingOccurrences(of: "\"", with: "&quot;")
        clean = clean.replacingOccurrences(of: "\'", with: "&apos;")
        while let controlChars = clean.rangeOfCharacter(from: CharacterSet.controlCharacters) {
            clean.removeSubrange(controlChars)
        }

        return clean

    }

}
