//
//  Cache.swift
//  DiskCache
//
//  Created by Jeremy Greenwood on 3/13/18.
//

import Foundation

public protocol Cache {
    func cache(_ data: Data, key: String) async throws
    func data(_ key: String) async throws -> Data?
    func delete(_ key: String) async throws
    func deleteAll() async throws
    func fileURL(_ filename: String) -> URL
}
