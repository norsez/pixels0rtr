//
//  HashUtils.swift
//  Pixels0rtr
//
//  Created by Norsez Orankijanan on 2/28/2560 BE.
//  Copyright © 2560 Bluedot. All rights reserved.
//

import Foundation

func hashValue(withHashValues hvs: Int...) -> Int {
    var result = 31
    for hv in hvs {
        result = (result &* 17) &+ hv
    }
    return result
}

func hashValue<T: Hashable>(objects: T?...) -> Int {
    var result = 31
    for object in objects {
        result = (result &* 17) &+ object.hashValue
    }
    return result
}

func hashValue<T: Hashable>(objects: T...) -> Int {
    var result = 31
    for object in objects {
        result = (result &* 17) &+ object.hashValue
    }
    return result
}

extension Optional where Wrapped: Hashable {
    var hashValue: Int {
        switch self {
        case .none: return 0
        case .some(let object): return object.hashValue
        }
    }
}
