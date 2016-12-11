//
//  Bitmap.swift
//  Pixels0rtr
//
//  Created by norsez on 12/4/16.
//  Copyright © 2016 Bluedot. All rights reserved.
//

import UIKit
import QuartzCore
class Bitmap {
    
    let width: Int
    let height: Int
    let context: CGContext
    
    var colorSpace: CGColorSpace {
        get {
            return CGColorSpaceCreateDeviceRGB()
        }
    }
    
    init(img: CGImage) {
        
        // Set image width, height
        width = img.width
        height = img.height
        
        // Declare the number of bytes per row. Each pixel in the bitmap in this
        // example is represented by 4 bytes; 8 bits each of red, green, blue, and
        // alpha.
        let bitmapBytesPerRow = width * 4
        
        // Use the generic RGB color space.
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
        
        // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
        // per component. Regardless of what the source image format is
        // (CMYK, Grayscale, and so on) it will be converted over to the format
        // specified here by CGBitmapContextCreate.
        context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bitmapBytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
        
        // draw the image onto the context
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        context.draw(img, in: rect)
    }
    
    var asCGImage: CGImage? {
        get {
            let result = context.makeImage().flatMap { $0 }
            return result
        }
    }
    
    func image(inRect rect: CGRect) -> CGImage?{
        if let cgimage = self.asCGImage {
            return cgimage.cropping(to: rect)
        }
        return nil
    }
    
}
