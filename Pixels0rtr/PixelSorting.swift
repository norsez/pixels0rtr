//
//  PixelSorting.swift
//  Pixels0rtr
//
//  Created by Norsez Orankijanan on 11/30/2559 BE.
//  Copyright © 2559 Bluedot. All rights reserved.
//

import UIKit

protocol PixelSorter {
    var name: String {get}
    func order(byColor color: UIColor, index: Float, totalColors: Int)->Float
}

class SorterBrightness: PixelSorter {
    var name: String {
        get {
            return "Brightness"
        }
    }
    
    func order(byColor color: UIColor, index: Float, totalColors: Int) -> Float {
        var b: CGFloat = 0;
        color.getHue(nil, saturation: nil, brightness: &b, alpha: nil)
        return Float(b);
        
    }
}

class PixelSorting: NSObject {

}
