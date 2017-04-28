//
//  XMLWritable.swift
//  SwiftXLS
//
//  Created by Carl Wieland on 4/27/17.
//  Copyright © 2017 Datum. All rights reserved.
//

import Foundation

protocol XMLWritable {
    func write(to handle: FileHandle) throws
}

extension String: XMLWritable {
    func write(to handle: FileHandle) throws {
        var clean = replacingOccurrences(of: "&", with: "&amp;")
        clean = clean.replacingOccurrences(of: "<", with: "&lt;")
        clean = clean.replacingOccurrences(of: ">", with: "&gt;")
        clean = clean.replacingOccurrences(of: "\"", with: "&quot;")
        clean = clean.replacingOccurrences(of: "\'", with: "&apos;")
        try handle.write(string: clean)
    }
}
