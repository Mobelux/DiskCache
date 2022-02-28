//
//  StorageType.swift
//  DiskCache
//
//  Created by Jeremy Greenwood on 3/13/18.
//

import Foundation

public typealias AppGroupID = String

public enum StorageType {
    // stores data in user's `caches` directory, which is volatile
    case temporary(_ subDirectory: SubDirectory? = nil)
    // stores data in user's `directory` directory
    case permanent(_ subDirectory: SubDirectory? = nil)
    // stores data in shared container, which is suitable to share data between app, extenstions, etc
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
