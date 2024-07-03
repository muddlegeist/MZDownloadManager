//
//  FileManager+RemapSandbox.swift
//  MZDownloadManager_Example
//
//  Created by Scott Puhl on 7/3/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation

extension FileManager {
    static func sandboxRemap(path: String) -> String? {
        
        // Determine which directory the old path belongs to
        let documentDirName = "Documents/"
        let cachesDirName = "Library/Caches/"
        let searchPathDirectory: FileManager.SearchPathDirectory
        let directoryBaseName: String
        
        if path.contains(documentDirName) {
            searchPathDirectory = .documentDirectory
            directoryBaseName = documentDirName
        } else if path.contains(cachesDirName) {
            searchPathDirectory = .cachesDirectory
            directoryBaseName = cachesDirName
        } else {
            print("Path does not seem to be from a known directory.")
            return nil
        }
        
        // Get the current URL for the detected directory
        guard let currentDirectoryURL = FileManager.default.urls(for: searchPathDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        // Extract the relative path
        guard let range = path.range(of: directoryBaseName) else {
            return nil
        }
        let relativePath = path[range.upperBound...]
        
        // Construct the new path by appending the relative path to the current directory URL
        let newPath = currentDirectoryURL.appendingPathComponent(String(relativePath)).path
        
        return newPath
    }
}
