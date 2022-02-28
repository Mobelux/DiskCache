//
//  Cache.swift
//  DiskCache
//
//  Created by Jeremy Greenwood on 3/13/18.
//

import Foundation

public protocol Cache {
    func syncCache(_ data: Data, key: String) throws
    func syncData(_ key: String) throws -> Data
    func syncDelete(_ key: String) throws
    func syncDeleteAll() throws
    func fileURL(_ key: String) -> URL

    // Async support
    func cache(_ data: Data, key: String) async throws
    func data(_ key: String) async throws -> Data
    func delete(_ key: String) async throws
    func deleteAll() async throws
}
