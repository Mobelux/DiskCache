//
//  SubDirectory.swift
//  DiskCache
//
//  Created by Jeremy Greenwood on 5/8/19.
//  Copyright © 2019 Mobelux. All rights reserved.
//

import Foundation

public enum SubDirectory {
    case images
    case custom(String)

    var value: String {
        switch self {
        case .images:
            return "images"
        case .custom(let value):
            return value
        }
    }
}
