//
//  MathUtils.swift
//  Pixels0rtr
//
//  Created by Norsez Orankijanan on 11/30/2559 BE.
//  Copyright © 2559 Bluedot. All rights reserved.
//

import UIKit

func fMap(value: Float, fromMin: Float, fromMax: Float, toMin: Float, toMax: Float) -> Float {
    let m = (toMax - toMin)/(fromMax - fromMin)
    return toMin + m * (value - fromMin)
}

func fRandom(min: Float, max: Float) -> Float {
    let CEIL: UInt32 = 10000
    let r = arc4random_uniform(CEIL)
    return fMap(value: Float(r), fromMin: 0, fromMax: Float(CEIL), toMin: min, toMax: max)
}
