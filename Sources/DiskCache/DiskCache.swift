//
//  Cache.swift
//  DiskCache
//
//  Created by Jeremy Greenwood on 3/13/18.
//

import Foundation

typealias VoidCheckedContinuation = CheckedContinuation<Void, Error>

/// Provides interfaces for caching and retrieving data to/from disk.
public class DiskCache: Cache {
    lazy var queue = DispatchQueue.global()
    let storageType: StorageType
    let appGroupID: String?

    public required init(storageType: StorageType, appGroupID: String? = nil) throws {
        self.storageType = storageType
        self.appGroupID = appGroupID
        try createDirectory(directoryURL)
    }

    public func cache(_ data: Data, key: String) async throws {
        try await withCheckedThrowingContinuation { [weak self] (continuation: VoidCheckedContinuation) -> Void in
            guard let self = self else {
                continuation.resume()
                return
            }

            self.queue.async {
                do {
                    try data.write(to: self.fileURL(key))
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    public func data(_ key: String) async throws -> Data? {
        try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self = self else {
                continuation.resume(returning: nil)
                return
            }

            self.queue.async {
                do {
                    let data = try Data(contentsOf: self.fileURL(key))
                    continuation.resume(returning: data)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    public func delete(_ key: String) async throws {
        try await withCheckedThrowingContinuation { [weak self] (continuation: VoidCheckedContinuation) -> Void in
            guard let self = self else {
                continuation.resume()
                return
            }

            self.queue.async {
                do {
                    try FileManager.default.removeItem(at: self.fileURL(key))
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    public func deleteAll() async throws {
        try await withCheckedThrowingContinuation { [weak self] (continuation: VoidCheckedContinuation) -> Void in
            guard let self = self else {
                continuation.resume()
                return
            }

            self.queue.async {
                do {
                    try FileManager.default.removeItem(at: self.directoryURL)
                    try self.createDirectory(self.directoryURL)
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
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
