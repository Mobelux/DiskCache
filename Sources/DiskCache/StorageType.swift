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
    case temporary(SubDirectory?)
    // stores data in user's `directory` directory
    case permanent(SubDirectory?)
    // stores data in shared container, which is suitable to share data between app, extenstions, etc
    case shared(AppGroupID)

    var subDirectory: String? {
        switch self {
        case .temporary(let subDirectory):
            return subDirectory?.value
        case .permanent(let subDirectory):
            return subDirectory?.value
        case .shared(let appGroupID):
            return appGroupID
        }
    }
}
