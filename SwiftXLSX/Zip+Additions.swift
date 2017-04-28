//
//  Zip+Additions.swift
//  SwiftXLS
//
//  Created by Carl Wieland on 4/28/17.
//  Copyright © 2017 Datum. All rights reserved.
//

import Foundation
import Zip

extension Zip {

    static func zipFiles(under parentDir: URL, to: URL, progress: ((_ progress: Double) -> ())? = nil) throws {
        // Get the directory contents urls (including subfolders urls)
        let directoryContents = try FileManager.default.contentsOfDirectory(at: parentDir, includingPropertiesForKeys: nil, options: [])

        try self.zipFiles(paths: directoryContents, zipFilePath: to, password: nil, progress: progress)

    }
}
