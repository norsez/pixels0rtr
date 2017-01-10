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

func expScale(value: Double, scaleFactor: Double) -> Double{
    return 1 - pow(value, scaleFactor)
}

extension UIImage {
    static func loadJPEG(with name:String) -> UIImage? {
        guard let path = Bundle.main.path(forResource: name, ofType: "jpg") else {
            Logger.log("can't find \(name).jpg in bundle")
            return nil
        }
        
        let image = UIImage(contentsOfFile: path)
        return image
    }
    
    
    func makeCopy() -> UIImage? {
        UIGraphicsBeginImageContext(self.size)
        self.draw(in: CGRect(x:0,y: 0,width: self.size.width,height: self.size.height))
        let copy = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return copy
    }
    
}
