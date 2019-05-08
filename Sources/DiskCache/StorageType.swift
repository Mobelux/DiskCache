//
//  StorageType.swift
//  DiskCache
//
//  Created by Jeremy Greenwood on 3/13/18.
//

import Foundation

public enum StorageType {
    case temporary(SubDirectory?)
    case permanent(SubDirectory?)

    var subDirectory: String? {
        switch self {
        case .temporary(let subDirectory):
            return subDirectory?.value
        case .permanent(let subDirectory):
            return subDirectory?.value
        }
    }
}
