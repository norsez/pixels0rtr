//
//  RGBA.swift
//  Pixels0rtr
//
//  Created by Norsez Orankijanan on 11/30/2559 BE.
//  Copyright © 2559 Bluedot. All rights reserved.
//

import UIKit
import C4




extension UIImage {
    
    fileprivate struct PixelData {
        var a:UInt8 = 255
        var r:UInt8
        var g:UInt8
        var b:UInt8
    }
    
    static fileprivate var rgbColorSpace: CGColorSpace {
        get {
            return CGColorSpaceCreateDeviceRGB()
        }
    }
    
    static fileprivate var bitmapInfo:CGBitmapInfo {
        get {
            return CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
        }
    }
    
    static fileprivate func imageFromARGB32Bitmap(pixels:[PixelData], width:UInt, height:UInt) -> UIImage {
        let bitsPerComponent:UInt = 8
        let bitsPerPixel:UInt = 32
        
        assert(pixels.count == Int(width * height))
        
        var data = pixels // Copy to mutable []
        let providerRef = CGDataProvider(
            data: NSData(bytes: &data, length: data.count * MemoryLayout<PixelData>.size)
        )
        
        let cgim = CGImage(
            width: Int(width),
            height: Int(height),
            bitsPerComponent: Int(bitsPerComponent),
            bitsPerPixel: Int(bitsPerPixel),
            bytesPerRow: Int(width) * MemoryLayout<PixelData>.size,
            space: rgbColorSpace,
            bitmapInfo: bitmapInfo,
            provider: providerRef!,
            decode: nil,
            shouldInterpolate: true,
            intent: CGColorRenderingIntent.defaultIntent
        )
        
        return UIImage(cgImage: cgim!)
    }
    
    static func image(withPixelColumns columns: [[UIColor]]) -> UIImage {
        var pixels = [PixelData]()
        for colIndex in 0..<columns.count {
            let col = columns[colIndex]
            for rowIndex in 0..<col.count {
                let color = col[rowIndex]
                var red: CGFloat = 0
                var green: CGFloat = 0
                var blue: CGFloat = 0
                color.getRed(&red, green: &green, blue: &blue, alpha: nil)
                let pdata = PixelData(a: 255, r: UInt8(255.0 * red), g: UInt8(255.0 * green), b: UInt8(255.0 * blue))
                pixels.append(pdata)
            }
        }
        
       return imageFromARGB32Bitmap(pixels: pixels, width: UInt(columns.count), height: UInt((columns.first?.count)!))
    }
    
    var pixelDataPointer: UnsafePointer<UInt8>? {
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
            return data
        }
    }
    
    func pixels(withColumnIndex colIndex: Int) -> [UIColor]? {
        
        if colIndex >= Int(self.size.width) {
            return nil
        }
        
        guard let data = self.pixelDataPointer else {
            return nil
        }
        
        var pixels = [UIColor]()
        let numberOfComponents = 4
        for y in 0..<Int(size.height) {
            let pixelData = ((Int(size.width) * y) + colIndex) * numberOfComponents
            let r = CGFloat(data[pixelData]) / 255.0
            let g = CGFloat(data[pixelData + 1]) / 255.0
            let b = CGFloat(data[pixelData + 2]) / 255.0
            let a = CGFloat(data[pixelData + 3]) / 255.0
            let c = UIColor(red: r, green: g, blue: b, alpha: a)
            pixels.append(c)
        }
        
        return pixels
    }
    
    var pixels: [UIColor]? {
        get {
            guard let data = self.pixelDataPointer else {
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
