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

    public required init(storageType: StorageType) {
        self.storageType = storageType

        // create the cache directory, opting not to make this initializer
        // failable at this time
        guard let url = directoryURL else {
            return
        }

        do {
            try createDirectory(url)
        } catch {
            print("\(#function) - \(error)")
        }
    }

    public func cache(_ data: Data, key: String) throws {
        guard let fileURL = fileURL(key) else {
            return
        }

        try data.write(to: fileURL)
    }

    public func data(_ key: String) throws -> Data? {
        guard let fileURL = fileURL(key) else {
            return nil
        }

        return try Data(contentsOf: fileURL)
    }

    public func delete(_ key: String) throws {
        guard let fileURL = fileURL(key) else {
            return
        }

        try FileManager.default.removeItem(at: fileURL)
    }
}

private extension DiskCache {
    var searchPath: FileManager.SearchPathDirectory {
        switch storageType {
        case .temporary: return .cachesDirectory
        case .permanent: return .documentDirectory
        }
    }

    var directoryURL: URL? {
        guard let searchPath = NSSearchPathForDirectoriesInDomains(searchPath, .userDomainMask, true).first else {
            return nil
        }

        let subDirectory = "com.mobelux.cache"
        return URL(fileURLWithPath: searchPath).appendingPathComponent(subDirectory)
    }

    func fileURL(_ filename: String) -> URL? {
        guard let directoryURL = directoryURL else {
            return nil
        }

        return directoryURL.appendingPathComponent(filename)
    }

    func createDirectory(_ url: URL) throws {
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
    }
}



