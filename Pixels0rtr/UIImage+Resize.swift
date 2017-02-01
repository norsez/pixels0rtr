//
//  UIImage+Resize.swift
//  Pixels0rtr
//
//  Created by norsez on 12/4/16.
//  Copyright © 2016 Bluedot. All rights reserved.
//

import UIKit

extension CGSize {
    
    func aspectFit(size: CGSize) -> CGSize {
        let isPortrait = self.width < self.height
        let factor = isPortrait ? size.height / self.height : size.width / self.width
        return CGSize(width: self.width * factor, height: self.height * factor)
    }
    
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
    
    func resize(toFitMaxPixels maxPixels: AppConfig.MaxSize) -> UIImage? {
        
        let selectedSize = maxPixels
        guard let toResize = self.makeCopy() else {
            return nil
        }
        
        if (selectedSize != AppConfig.MaxSize.pxTrueSize) {
            let size = CGSize(width: selectedSize.pixels, height:selectedSize.pixels)
            let fitSize = toResize.size.aspectFit(size: size)
            
            if let output = toResize.resize(fitSize) {
                return output
            }
        }
        return nil
    }
    
    
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
    
    func resize(_ size: CGSize) -> UIImage? {
        guard let cgImage = self.cgImage?.copy() else {
            Logger.log("can't make a copy of CGImage")
            return nil
        }
        
        let width = size.width
        let height = size.height
        let bitsPerComponent = cgImage.bitsPerComponent
        let bytesPerRow = cgImage.bitsPerComponent * Int(width)
        let colorSpace = cgImage.colorSpace ?? CGColorSpaceCreateDeviceRGB()
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

