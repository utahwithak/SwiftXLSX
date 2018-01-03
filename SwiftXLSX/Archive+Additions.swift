//
//  Archive+Additions.swift
//  SwiftXLSX
//
//  Created by Carl Wieland on 12/28/17.
//  Copyright © 2017 Datum. All rights reserved.
//

import Foundation

extension Archive {
    public func extractAll(of file: String) throws -> XMLDocument {
        return try extractAll(of: file) {
            return try XMLDocument(data: $0)
        }
    }
    
    public func extractAll<T>(of file: String, handler: (Data) throws -> T) throws -> T {

        guard let entry = self[file] else {
            throw SwiftXLSX.missingContent("Missing expected entry:\(file)")
        }

        return try extractAll(of: entry, handler: handler)
    }

    public func extractAll<T>(of entry: Entry, handler: (Data) throws -> T) throws -> T {

        var tmpData = Data()
        _ = try extract(entry) { data in
            tmpData += data
        }

        return try handler(tmpData)
    }
}
