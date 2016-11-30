//
//  SortPattern.swift
//  Pixels0rtr
//
//  Created by Norsez Orankijanan on 11/30/2559 BE.
//  Copyright © 2559 Bluedot. All rights reserved.
//

import UIKit
import C4
protocol SortPattern {
    var name: String {get}
    func initialize(withWidth width:Int, height: Int, amount: Float, motion: Float)
    func resetSubsortBlock(withRow row: Int, column: Int) -> Bool
}

class PatternClass : SortPattern {
    var resetRowIndexByCol: [Int] = []
    var name: String {
        get {
            return "Classic"
        }
    }
    
    func initialize(withWidth width: Int, height: Int, amount: Float, motion: Float) {
        resetRowIndexByCol = [Int]()
        let factor = 1.0/(amount + 0.00001);
        let _max: Float = 2.0 * factor;
        let _min: Float = 25.0 * factor;
        for _ in 0..<width {
            let r = fRandom(min: Float(height)/_min, max: Float(height)/_max)
            let v = max(2.0, r) + motion * 25.0
            resetRowIndexByCol.append(Int(v))
        }
        
    }
    
    func resetSubsortBlock(withRow row: Int, column: Int) -> Bool {
        return row % resetRowIndexByCol[column] == 0;
    }
}
