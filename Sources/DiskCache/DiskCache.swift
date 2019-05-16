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

    public required init(storageType: StorageType) throws {
        self.storageType = storageType
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
}

private extension DiskCache {
    var searchPath: FileManager.SearchPathDirectory {
        switch storageType {
        case .temporary: return .cachesDirectory
        case .permanent: return .documentDirectory
        }
    }

    var directoryURL: URL {
        guard let searchPath = NSSearchPathForDirectoriesInDomains(searchPath, .userDomainMask, true).first else {
            fatalError("\(#function) Fatal: Cannot get user directory.")
        }

        var directoryURL = URL(fileURLWithPath: searchPath).appendingPathComponent("com.mobelux.cache")

        if let subDirectory = storageType.subDirectory {
            directoryURL.appendPathComponent(subDirectory, isDirectory: true)
        }

        return directoryURL
    }

    func fileURL(_ filename: String) -> URL {
        return directoryURL.appendingPathComponent(filename)
    }

    func createDirectory(_ url: URL) throws {
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
    }
}
