//
//  RGBA.swift
//  Pixels0rtr
//
//  Created by Norsez Orankijanan on 11/30/2559 BE.
//  Copyright © 2559 Bluedot. All rights reserved.
//

import UIKit
struct Pixel {
    var r: Int
    var g: Int
    var b: Int
    var a: Int
}

extension UIImage {
    
    
    static var rgbColorSpace: CGColorSpace {
        get {
            return CGColorSpaceCreateDeviceRGB()
        }
    }
    
    static var bitmapInfo:CGBitmapInfo {
        get {
            return CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
        }
    }
    
    static func imageFromARGB32Bitmap(pixels:[Pixel], width:UInt, height:UInt) -> UIImage {
        let bitsPerComponent:UInt = 8
        let bitsPerPixel:UInt = 32
        
        assert(pixels.count == Int(width * height))
        
        var data = pixels // Copy to mutable []
        let providerRef = CGDataProvider(
            data: NSData(bytes: &data, length: data.count * MemoryLayout<Pixel>.size)
        )
        
        let cgim = CGImage(
            width: Int(width),
            height: Int(height),
            bitsPerComponent: Int(bitsPerComponent),
            bitsPerPixel: Int(bitsPerPixel),
            bytesPerRow: Int(width) * MemoryLayout<Pixel>.size,
            space: rgbColorSpace,
            bitmapInfo: bitmapInfo,
            provider: providerRef!,
            decode: nil,
            shouldInterpolate: true,
            intent: CGColorRenderingIntent.defaultIntent
        )
        
        return UIImage(cgImage: cgim!)
    }
    
    static func image(withPixelColumns columns: [[Pixel]]) -> UIImage {
        var pixels = [Pixel]()
        for colIndex in 0..<columns.count {
            let col = columns[colIndex]
            for rowIndex in 0..<col.count {
                pixels.append(col[rowIndex])
            }
        }
        
       return imageFromARGB32Bitmap(pixels: pixels, width: UInt(columns.count), height: UInt((columns.first?.count)!))
    }
    
    var PixelPointer: UnsafePointer<UInt8>? {
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
    
    func pixels(withColumnIndex colIndex: Int) -> [Pixel]? {
        
        if colIndex >= Int(self.size.width) {
            return nil
        }
        
        guard let data = self.PixelPointer else {
            return nil
        }
        
        var pixels = [Pixel]()
        let numberOfComponents = 4
        for y in 0..<Int(size.height) {
            let p = ((Int(size.width) * y) + colIndex) * numberOfComponents
            
            let pixel = Pixel(r:Int(data[p]),g:Int(data[p+1]),b:Int(data[p+2]),a:Int(data[p+3]))
            pixels.append(pixel)
        }
        
        return pixels
    }
    
    var pixels: [Pixel]? {
        get {
            guard let data = self.PixelPointer else {
                return nil
            }
            let numberOfComponents = 4
            var pixels = [Pixel]()
            
            for x in 0..<Int(size.width) {
                for y in 0..<Int(size.height) {
                    let p = ((Int(size.width) * y) + x) * numberOfComponents
                    let pixel = Pixel(r:Int(data[p]),g:Int(data[p+1]),b:Int(data[p+2]),a:Int(data[p+3]))
                    pixels.append(pixel)
                }
            }
            
            return pixels
        }
        
    }
    
}
