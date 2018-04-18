//
//  StorageType.swift
//  DiskCache
//
//  Created by Jeremy Greenwood on 3/13/18.
//

import Foundation

public enum StorageType {
    case temporary(String?)
    case permanent(String?)

    var subDirectory: String? {
        switch self {
        case .temporary(let subDirectory):
            return subDirectory
        case .permanent(let subDirectory):
            return subDirectory
        }
    }
}
