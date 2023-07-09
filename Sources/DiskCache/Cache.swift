//
//  Cache.swift
//  DiskCache
//
//  Created by Jeremy Greenwood on 3/13/18.
//

import Foundation

/// A class of types providing interfaces for caching and retrieving data to/from disk.
public protocol Cache {

    /// Synchronously writes `data` to disk.
    /// - Parameters:
    ///   - data: The data to write to disk.
    ///   - key: A unique key used to identify `data`.
    func syncCache(_ data: Data, key: String) throws

    /// Synchronously get data from the cache. If data does not exist for `key`, an error will be thrown.
    /// - Parameter key: A unique key used to identify `data`.
    /// - Returns: An instance of Data which was previously stored on disk.
    func syncData(_ key: String) throws -> Data

    /// Synchronously deletes cached data. If data does not exist for `key`, an error will be thrown.
    /// - Parameter key: A unique key used to identify `data`.
    func syncDelete(_ key: String) throws

    /// Deletes the cache directory and all or its contents, then recreates the cache directory.
    func syncDeleteAll() throws

    /// Constructs the full file url for the given key. Useful for determiniing if a something is cached for the key.
    /// - Parameter key: A unique key used to identify `data`.
    /// - Returns: The file url for a cached it, based on `storageType`.
    func fileURL(_ key: String) -> URL

    // Async support

    /// Asynchronously writes `data` to disk.
    /// - Parameters:
    ///   - data: The data to write to disk.
    ///   - key: A unique key used to identify `data`.
    func cache(_ data: Data, key: String) async throws

    /// Asynchronously get data from the cache. If data does not exist for `key`, an error will be thrown.
    /// - Parameter key: A unique key used to identify `data`.
    /// - Returns: An instance of Data which was previously stored on disk.
    func data(_ key: String) async throws -> Data

    /// Asynchronously deletes cached data. If data does not exist for `key`, an error will be thrown.
    /// - Parameter key: A unique key used to identify `data`.
    func delete(_ key: String) async throws

    /// Deletes the cache directory and all or its contents, then recreates the cache directory.
    func deleteAll() async throws
}
