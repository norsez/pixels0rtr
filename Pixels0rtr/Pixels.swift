//
//  RGBA.swift
//  Pixels0rtr
//
//  Created by Norsez Orankijanan on 11/30/2559 BE.
//  Copyright © 2559 Bluedot. All rights reserved.
//

import UIKit

extension UIImage {
    
//    subscript (x: Int, y: Int) -> UIColor? {
//        
//        if x < 0 || x > Int(size.width) || y < 0 || y > Int(size.height) {
//            return nil
//        }
//        
//        let provider = CGImageGetDataProvider(self.CGImage)
//        let providerData = CGDataProviderCopyData(provider)
//        let data = CFDataGetBytePtr(providerData)
//        
//        let numberOfComponents = 4
//        let pixelData = ((Int(size.width) * y) + x) * numberOfComponents
//        
//        let r = CGFloat(data[pixelData]) / 255.0
//        let g = CGFloat(data[pixelData + 1]) / 255.0
//        let b = CGFloat(data[pixelData + 2]) / 255.0
//        let a = CGFloat(data[pixelData + 3]) / 255.0
//        
//        return UIColor(red: r, green: g, blue: b, alpha: a)
//    }
    
    var pixels: [UIColor]? {
        get {
            guard let cgi = cgImage else {
                return nil
            }
            
            guard let provider = cgi.dataProvider else {
                return nil
            }
            
            let providerData = provider.data
            guard let data = CFDataGetBytePtr(providerData) else {
                return nil
            }
            let numberOfComponents = 4
            
            
            var pixels = [UIColor]()
            
            for x in 0..<Int(size.width) {
                for y in 0..<Int(size.height) {
                    let pixelData = ((Int(size.width) * y) + x) * numberOfComponents
                    let r = CGFloat(data[pixelData]) / 255.0
                    let g = CGFloat(data[pixelData + 1]) / 255.0
                    let b = CGFloat(data[pixelData + 2]) / 255.0
                    let a = CGFloat(data[pixelData + 3]) / 255.0
                    
                    let c = UIColor(red: r, green: g, blue: b, alpha: a)
                    pixels.append(c)
                }
            }
            
            return pixels
        }
        
    }
    
}
