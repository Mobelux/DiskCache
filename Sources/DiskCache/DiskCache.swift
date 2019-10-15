//
//  Cache.swift
//  DiskCache
//
//  Created by Jeremy Greenwood on 3/13/18.
//

import Foundation

/// Provides interfaces for caching and retrieving data to/from disk. This implementation executes
/// all tasks on the current queue. Consumers should manage dispatching tasks to background queues if needed
public class DiskCache: Cache {
    let storageType: StorageType
    let appGroupID: String?

    public required init(storageType: StorageType, appGroupID: String? = nil) throws {
        self.storageType = storageType
        self.appGroupID = appGroupID
        try createDirectory(directoryURL)
    }

    public func cache(_ data: Data, key: String) throws {
        try data.write(to: fileURL(key))
    }

    public func data(_ key: String) throws -> Data? {
        return try Data(contentsOf: fileURL(key))
    }

    public func delete(_ key: String) throws {
        try FileManager.default.removeItem(at: fileURL(key))
    }

    public func deleteAll() throws {
        try FileManager.default.removeItem(at: directoryURL)
        try createDirectory(directoryURL)
    }

    public func fileURL(_ filename: String) -> URL {
        return directoryURL.appendingPathComponent(filename)
    }
}

private extension DiskCache {
    var searchPath: FileManager.SearchPathDirectory {
        switch storageType {
        case .temporary: return .cachesDirectory
        case .permanent: return .documentDirectory
        }
    }

    var directoryURL: URL {
        var basePath: String {
            if let appGroupID = appGroupID {
                guard let sharedPath = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID)?.path else {
                    fatalError("\(#function) Fatal: Cannot get shared directory.")
                }

                return sharedPath
            } else {
                guard let searchPath = NSSearchPathForDirectoriesInDomains(searchPath, .userDomainMask, true).first else {
                    fatalError("\(#function) Fatal: Cannot get user directory.")
                }

                return searchPath
            }
        }

        var directoryURL = URL(fileURLWithPath: basePath).appendingPathComponent("com.mobelux.cache")

        if let subDirectory = storageType.subDirectory {
            directoryURL.appendPathComponent(subDirectory, isDirectory: true)
        }

        return directoryURL
    }

    func createDirectory(_ url: URL) throws {
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
    }
}
