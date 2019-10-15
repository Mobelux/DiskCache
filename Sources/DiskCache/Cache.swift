//
//  Cache.swift
//  DiskCache
//
//  Created by Jeremy Greenwood on 3/13/18.
//

import Foundation

public protocol Cache {
    func cache(_ data: Data, key: String) throws
    func data(_ key: String) throws -> Data?
    func delete(_ key: String) throws
    func deleteAll() throws
    func fileURL(_ filename: String) -> URL
}
