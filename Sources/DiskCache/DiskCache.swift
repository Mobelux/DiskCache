//
//  Cache.swift
//  DiskCache
//
//  Created by Jeremy Greenwood on 3/13/18.
//

import Foundation

typealias VoidUnsafeContinuation = UnsafeContinuation<Void, Error>

/// Provides interfaces for caching and retrieving data to/from disk.
public class DiskCache: Cache {
    let storageType: StorageType

    /// Intializes a new instance of `DiskCache`. The path to the cache is created if not already presents. Throws if path cannot be created for some reason.
    /// - Parameter storageType: The type of storage (on disk) the cache uses. This influences where the cache will be created.
    public required init(storageType: StorageType) throws {
        self.storageType = storageType
        try createDirectory(directoryURL)
    }

}

// MARK: - Asynchronous Methods
public extension DiskCache {
    /// Asynchronously writes `data` to disk.
    /// - Parameters:
    ///   - data: The data to write to disk
    ///   - key: A unique key used to identify `data`.
    func cache(_ data: Data, key: String) async throws {
        try await withUnsafeThrowingContinuation {(continuation: VoidUnsafeContinuation) -> Void in
            do {
                try syncCache(data, key: key)
                continuation.resume()
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    /// Asynchronously get data from the cache. If data does not exist for `key`, an error with code `NSFileReadNoSuchFileError` will be thrown.
    /// - Parameter key: A unique key used to identify `data`.
    /// - Returns: An instance of Data which was previously stored on disk.
    func data(_ key: String) async throws -> Data {
        try await withUnsafeThrowingContinuation { continuation in
            do {
                let data = try syncData(key)
                continuation.resume(returning: data)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    /// Asynchronously deletes cached data. If data does not exist for `key`, an error with code `NSFileReadNoSuchFileError` will be thrown.
    /// - Parameter key: A unique key used to identify `data`.
    func delete(_ key: String) async throws {
        try await withUnsafeThrowingContinuation { (continuation: VoidUnsafeContinuation) -> Void in
            do {
                try syncDelete(key)
                continuation.resume()
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    /// Deletes the cache directory and all or its contents, then recreates the cache directory.
    func deleteAll() async throws {
        try await withUnsafeThrowingContinuation { (continuation: VoidUnsafeContinuation) -> Void in
            do {
                try syncDeleteAll()
                continuation.resume()
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    /// Constructs the full file url for the given key. Useful for determiniing if a something is cached for the key.
    /// - Parameter key: A unique key used to identify `data`.
    /// - Returns: The file url for a cached it, based on `storageType`
    func fileURL(_ key: String) -> URL {
        return directoryURL.appendingPathComponent(key)
    }
}

// MARK: - Synchronous Methods
public extension DiskCache {
    /// Synchronously writes `data` to disk.
    /// - Parameters:
    ///   - data: The data to write to disk
    ///   - key: A unique key used to identify `data`
    func syncCache(_ data: Data, key: String) throws {
        try data.write(to: fileURL(key))
    }

    /// Synchronously get data from the cache. If data does not exist for `key`, an error with code `NSFileReadNoSuchFileError` will be thrown.
    /// - Parameter key: A unique key used to identify `data`.
    /// - Returns: An instance of Data which was previously stored on disk.
    func syncData(_ key: String) throws -> Data {
        try Data(contentsOf: fileURL(key))
    }

    /// Synchronously deletes cached data. If data does not exist for `key`, an error with code `NSFileReadNoSuchFileError` will be thrown.
    /// - Parameter key: A unique key used to identify `data`.
    func syncDelete(_ key: String) throws {
        try FileManager.default.removeItem(at: fileURL(key))
    }

    /// Deletes the cache directory and all or its contents, then recreates the cache directory.
    func syncDeleteAll() throws {
        try FileManager.default.removeItem(at: directoryURL)
        try createDirectory(directoryURL)
    }
}

extension DiskCache {
    var searchPathDirectory: FileManager.SearchPathDirectory? {
        switch storageType {
        case .temporary: return .cachesDirectory
        case .permanent: return .documentDirectory
        case .shared: return nil
        }
    }

    var directoryURL: URL {
        var basePath: URL {
            switch storageType {
            case .temporary, .permanent:
                guard let searchPathDirectory = searchPathDirectory,
                      let searchPath = FileManager.default.urls(for: searchPathDirectory,in: .userDomainMask)
                        .first else {
                            fatalError("\(#function) Fatal: Cannot get user directory.")
                        }

                return searchPath

            case let .shared(appGroupID, _):
                guard let sharedPath = FileManager.default
                        .containerURL(forSecurityApplicationGroupIdentifier: appGroupID)
                else {
                    fatalError("\(#function) Fatal: Cannot get shared directory.")
                }

                return sharedPath
            }
        }

        var directoryURL = basePath.appendingPathComponent("com.mobelux.cache")

        if let subDirectory = storageType.subDirectory {
            directoryURL.appendPathComponent(subDirectory, isDirectory: true)
        }

        return directoryURL
    }

    func createDirectory(_ url: URL) throws {
        try FileManager.default
            .createDirectory(
                at: url,
                withIntermediateDirectories: true,
                attributes: nil)
    }
}
