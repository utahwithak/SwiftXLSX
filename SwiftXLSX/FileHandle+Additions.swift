//
//  FileHandle+Additions.swift
//  SwiftXLS
//
//  Created by Carl Wieland on 4/27/17.
//  Copyright © 2017 Datum. All rights reserved.
//

import Foundation
extension FileHandle {

    func write(string: String, encoding: String.Encoding = .utf8) throws {
        guard let data = string.data(using: encoding) else {
            throw NSError(domain: "com.datum.SwiftXLS", code: 5, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Unable to convert string to encoding", comment: " String conversion error")])
        }
        write(data)

    }

    func writeXMLHeader() throws {
        try write(string: "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n")
    }

}
