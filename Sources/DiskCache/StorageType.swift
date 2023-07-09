//
//  StorageType.swift
//  DiskCache
//
//  Created by Jeremy Greenwood on 3/13/18.
//

import Foundation

/// An identifier specifying a group to which an app belongs.
public typealias AppGroupID = String

/// A location where data may be stored.
public enum StorageType {
    /// Stores data in user's `caches` directory, which is volatile.
    case temporary(_ subDirectory: SubDirectory? = nil)
    /// Stores data in user's `directory` directory.
    case permanent(_ subDirectory: SubDirectory? = nil)
    /// Stores data in shared container, which is suitable to share data between app, extenstions, etc.
    case shared(_ appGroupID: AppGroupID, subDirectory: SubDirectory? = nil)

    var subDirectory: String? {
        switch self {
        case .temporary(let subDirectory):
            return subDirectory?.value
        case .permanent(let subDirectory):
            return subDirectory?.value
        case let .shared(_, subDirectory):
            return subDirectory?.value
        }
    }
}
