//
//  MathUtils.swift
//  Pixels0rtr
//
//  Created by Norsez Orankijanan on 11/30/2559 BE.
//  Copyright © 2559 Bluedot. All rights reserved.
//

import UIKit

func fMap(value: Double, fromMin: Double, fromMax: Double, toMin: Double, toMax: Double) -> Double {
    let m = (toMax - toMin)/(fromMax - fromMin)
    return toMin + m * (value - fromMin)
}

func fRandom(min: Double, max: Double) -> Double {
    let CEIL: UInt32 = 10000
    let r = arc4random_uniform(CEIL)
    return fMap(value: Double(r), fromMin: 0, fromMax: Double(CEIL), toMin: min, toMax: max)
}
