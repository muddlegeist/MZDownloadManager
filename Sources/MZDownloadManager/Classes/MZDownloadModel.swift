//
//  MZDownloadModel.swift
//  MZDownloadManager
//
//  Created by Muhammad Zeeshan on 19/04/2016.
//  Copyright © 2016 ideamakerz. All rights reserved.
//

import UIKit

protocol FileLocationResolvable {
    func resolveToUrl() -> URL?
    func resolveToPath() -> String?
}

public enum RelativeBase: String, Codable, FileLocationResolvable {
    case documents
    case temporary
    
    func resolveToUrl() -> URL? {
        return Self.currentBaseDirectory(base: self)
    }
    
    func resolveToPath() -> String? {
        return Self.currentBaseDirectory(base: self)?.path(percentEncoded: false)
    }
    
    static var currentDocumentDirectory:URL?
    {
        let location:FileManager.SearchPathDirectory = .documentDirectory
        
        if let documentDirectory = FileManager.default.urls(for: location, in: .userDomainMask).last
        {
            return documentDirectory
        }
        
        return nil
    }
    
    static var currentTempDirectory:URL {
        let tempDirectory = FileManager.default.temporaryDirectory
        
        return tempDirectory
    }
    
    static func currentBaseDirectory(base:RelativeBase) -> URL? {
        if base == .temporary {
            return Self.currentTempDirectory
        }
        else {
            //defualt to the document directory
            return Self.currentDocumentDirectory
        }
    }
}

public struct RelativeLocation: Codable, FileLocationResolvable {
    
    var base:RelativeBase
    var path:String

    func resolveToUrl() -> URL? {
        guard let baseUrl = self.base.resolveToUrl() else {
            return nil
        }
        
        if self.path.isEmpty {
            return baseUrl
        }
        
        return baseUrl.appending(path: self.path)
    }
    
    func resolveToPath() -> String? {
        return self.resolveToUrl()?.path(percentEncoded: false)
    }
}

public enum FileLocation: FileLocationResolvable {
    case specific(String)
    case relative(RelativeLocation)
    
    func resolveToUrl() -> URL? {
        switch self {
        case .specific(let specificLocation):
            let url = URL(string: specificLocation)
            return url
            
        case .relative(let relativeLocation):
            let url = relativeLocation.resolveToUrl()
            return url
        }
    }
    
    func resolveToPath() -> String? {
        switch self {
        case .specific(let specificLocation):
            return specificLocation
            
        case .relative(let relativeLocation):
            let path = relativeLocation.resolveToPath()
            return path
        }
    }
}

public enum TaskStatus: Int {
    case unknown, gettingInfo, downloading, paused, failed
    
    public func description() -> String {
        switch self {
        case .gettingInfo:
            return "GettingInfo"
        case .downloading:
            return "Downloading"
        case .paused:
            return "Paused"
        case .failed:
            return "Failed"
        default:
            return "Unknown"
        }
    }
}

open class MZDownloadModel: NSObject {
    
    open var fileName: String!
    open var fileURL: String!
    open var status: String = TaskStatus.gettingInfo.description()
    
    open var file: (size: Float, unit: String)?
    open var downloadedFile: (size: Float, unit: String)?
    
    open var remainingTime: (hours: Int, minutes: Int, seconds: Int)?
    
    open var speed: (speed: Float, unit: String)?
    
    open var progress: Float = 0
    
    open var task: URLSessionDownloadTask?
    
    open var startTime: Date?
    
    fileprivate(set) open var destination: FileLocation = .relative(RelativeLocation(base: .temporary, path: ""))
    
    fileprivate convenience init(fileName: String, fileURL: String) {
        self.init()
        
        self.fileName = fileName
        self.fileURL = fileURL
    }
    
    convenience init(fileName: String, fileURL: String, destination: FileLocation) {
        self.init(fileName: fileName, fileURL: fileURL)
        
        self.destination = destination
    }
}
