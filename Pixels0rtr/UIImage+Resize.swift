//
//  UIImage+Resize.swift
//  Pixels0rtr
//
//  Created by norsez on 12/4/16.
//  Copyright © 2016 Bluedot. All rights reserved.
//

import UIKit

extension CGSize {
    func fit(maxPixels: Int) -> CGSize {
        if Int(self.width) <= maxPixels &&
            Int(self.height) <= maxPixels {
            return self
        }
        
        let isPortrait = self.width <= self.height
        
        var factor: CGFloat = 1
        if isPortrait {
            factor = CGFloat(maxPixels)/self.height
        }else {
            factor = CGFloat(maxPixels)/self.width
        }
        
        let resizedSize = CGSize(width: CGFloat(factor) * self.width, height: CGFloat(factor) * self.height)
        return resizedSize
    }
}

extension UIImage {
    func resize(byMaxPixels maxPixels: Int) -> UIImage? {
        return self.resize(self.size.fit(maxPixels: maxPixels))
        
    }
    
    func resizeToFit(size: CGSize) -> UIImage? {
    
        if Int(self.size.width) <= Int(size.width) && Int(self.size.height) <= Int(size.height) {
            return self
        }
        
        var factor = 1.0
        let isPortrait = self.size.width < self.size.height
        
        if isPortrait {
           factor = Double(size.width)/Double(self.size.width)
        }else {
            factor = Double(size.height)/Double(self.size.height)
        }
        
        let size = CGSize(width: self.size.width * CGFloat(factor), height: self.size.height * CGFloat(factor))
        return self.resize(size)
        
    }
    
//    func resize(_ size:CGSize) -> UIImage? {
//        
//        let hasAlpha = false
//        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
//        
//        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
//        self.draw(in: CGRect(origin: CGPoint.zero, size: size))
//        
//        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return scaledImage
//    }
    
    func resize(_ size: CGSize) -> UIImage? {
        guard let cgImage = self.cgImage else {
            Logger.log("can't make a copy of CGImage")
            return nil
        }
        
        let width = size.width
        let height = size.height
        let bitsPerComponent = cgImage.bitsPerComponent
        let bytesPerRow = max(cgImage.bytesPerRow, 8192)
        let colorSpace = cgImage.colorSpace!
        let bitmapInfo = cgImage.bitmapInfo
        
        guard let context = CGContext(data: nil, width: Int(width), height:Int(height), bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
            else {
                Logger.log("can't create bitmap context")
                return nil
        }
        
        context.interpolationQuality = CGInterpolationQuality.high
        context.draw(cgImage, in: CGRect(origin: CGPoint.zero, size: CGSize(width: CGFloat(width), height: CGFloat(height))))
        
        
        
        let scaledImage = context.makeImage().flatMap { UIImage(cgImage: $0) }
        return scaledImage
    }
}

