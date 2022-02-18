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

    public required init(storageType: StorageType) throws {
        self.storageType = storageType
        try createDirectory(directoryURL)
    }

    public func cache(_ data: Data, key: String) async throws {
        try await withCheckedThrowingContinuation { [weak self] (continuation: VoidCheckedContinuation) -> Void in
            guard let self = self else {
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

    public func data(_ key: String) async throws -> Data {
        try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self = self else {
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
