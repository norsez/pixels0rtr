//
//  Image+Utils.swift
//  Pixels0rtr
//
//  Created by norsez on 12/6/16.
//  Copyright © 2016 Bluedot. All rights reserved.
//

import UIKit
import CoreImage
import AVFoundation

extension UIImage {
    
    func colorArrays() -> [[SortColor]]{
        
        let bitmap = Bitmap(img: self.cgImage!)
        guard let correctedBitmapCGImage = bitmap.asCGImage else {
            Logger.log("can't create correct bitmap format")
            return []
        }
        let imageProvider = correctedBitmapCGImage.dataProvider
        let imageData = imageProvider?.data
        
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(imageData)
        
        var results = [[SortColor]]()
        let NUM_COMPS = 4 //know this from how bitmap object defines context
        //let DATA_SIZE = Int(size.width)*Int(size.height) * NUM_COMPS
        
        for x in 0..<Int(self.size.width) {
            var colorCols = [SortColor]()
            for y in 0..<Int(self.size.height) {
                let idx = (y * Int(size.width) + x) * NUM_COMPS
                let c = SortColor(withRed: data[idx + 1],
                                  green: data[idx + 2],
                                  blue: data[idx + 3],
                                  alpha: data[idx])
                colorCols.append(c)
            }
            
            results.append(colorCols)
        }
        
        return results
    }
    
    func blurredImage(withRadius radius: Double) -> UIImage {
        let imageToBlur = CIImage(image: self)
        let blurfilter = CIFilter(name: "CIGaussianBlur")
        blurfilter?.setValue(imageToBlur, forKey: "inputImage")
        blurfilter?.setValue(radius, forKey: "inputRadius")
        let resultImage = blurfilter?.value(forKey: "outputImage") as! CIImage
        let blurredImage = UIImage(ciImage: resultImage)
        return blurredImage
    }
    
    
    static func image(withView view:UIView, inRect rect: CGRect) -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 1)
        guard let context = UIGraphicsGetCurrentContext() else {
            print("can't get view context")
            return nil
        }
        view.layer.render(in: context)
        var img = UIGraphicsGetImageFromCurrentImageContext();
        guard let cgimg = img?.cgImage?.cropping(to: rect) else {
            print("can't create cropped CGImage")
            return nil
        }
        img = UIImage(cgImage: cgimg)
        UIGraphicsEndImageContext();
        return img
    }
    
    
    
    func createImageView() -> UIImageView {
        let iv = UIImageView(image: self)
        return iv
    }
    
    func scanLine(atIndex index: Int) -> CGImage?{
        var rect = CGRect.zero
        rect.origin = CGPoint(x:index, y: 0)
        rect.size = CGSize(width: 1, height: self.size.height)
        return self.cgImage?.cropping(to: rect)
        
    }
    
    func upsideDown () -> UIImage{
        var transform: CGAffineTransform = CGAffineTransform.identity
        transform = transform.translatedBy(x: 0, y: size.height)
        transform = transform.scaledBy(x: 1, y: -1)
        
        let ctx: CGContext = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0, space: self.cgImage!.colorSpace!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        
        ctx.concatenate(transform)
        ctx.draw(self.cgImage!, in: CGRect(origin: CGPoint.zero, size: size))
        let cgImage: CGImage = ctx.makeImage()!
        
        return UIImage(cgImage: cgImage)
    }
    
    func fixedOrientation() -> UIImage {
        return self
//        switch imageOrientation {
//        case .up, .upMirrored:
//            return self
//        case .down, .downMirrored:
//            return self.image(withRotation: .m_pi)
//        case .right, .rightMirrored:
//            return self.image(withRotation: .m_pi)
//        case .left, .leftMirrored:
//            return self.image(withRotation: .Double.pi / 2)
//        }
    }
    
    func image(withRotation radians: CGFloat) -> UIImage {
        let cgImage = self.cgImage!
        let LARGEST_SIZE = CGFloat(max(self.size.width, self.size.height))
        let context = CGContext.init(data: nil, width:Int(LARGEST_SIZE), height:Int(LARGEST_SIZE), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: cgImage.colorSpace!, bitmapInfo: cgImage.bitmapInfo.rawValue)!
        
        var drawRect = CGRect.zero
        drawRect.size = self.size
        let drawOrigin = CGPoint(x: (LARGEST_SIZE - self.size.width) * 0.5,y: (LARGEST_SIZE - self.size.height) * 0.5)
        drawRect.origin = drawOrigin
        drawRect = drawRect.integral
        var tf = CGAffineTransform.identity
        tf = tf.translatedBy(x: LARGEST_SIZE * 0.5, y: LARGEST_SIZE * 0.5)
        tf = tf.rotated(by: CGFloat(radians))
        tf = tf.translatedBy(x: LARGEST_SIZE * -0.5, y: LARGEST_SIZE * -0.5)
        context.concatenate(tf)
        context.draw(cgImage, in: drawRect)
        var rotatedImage = context.makeImage()!
        drawRect = drawRect.applying(tf)
        rotatedImage = rotatedImage.cropping(to: drawRect)!
        let resultImage = UIImage(cgImage: rotatedImage)
        return resultImage
    }
    
    func image(underImage anotherImage:UIImage) -> UIImage? {
        guard let thisImage = self.cgImage else {
            return nil
        }
        
        guard let topImage = anotherImage.cgImage else {
            print("can't get top image ")
            return nil
        }
        
        let context = CGContext.init(data: nil, width: thisImage.width, height: thisImage.height, bitsPerComponent: thisImage.bitsPerComponent, bytesPerRow: thisImage.bytesPerRow, space: thisImage.colorSpace!, bitmapInfo: thisImage.bitmapInfo.rawValue)
        
        var drawRect = CGRect.zero
        drawRect.size = self.size
        context?.draw(thisImage, in: drawRect)
        
        drawRect.size = anotherImage.size
        context?.draw(topImage, in: drawRect)
        
        if let cgImage = context?.makeImage() {
            return UIImage(cgImage: cgImage)
        }else {
            return nil
        }
        
    }
    
    /**
     recompress a jpg repeatedly
     */
    func recompressedImage(image: UIImage, compressionRate: CGFloat, times: Int) -> UIImage? {
        
        var currentImage = image
        
        for _ in 0..<times {
            if let data = UIImageJPEGRepresentation(currentImage, compressionRate),
                let img =  UIImage(data: data){
                 currentImage = img
            }else {
                return nil
            }
        }
        return currentImage
        
    }
    
    func save(withFileName filename: String, url: inout URL?) throws -> Bool{
        let folders = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        if folders.count == 0 {
            return false
        }
        
        var path = URL(fileURLWithPath: folders.first!)
        path = path.appendingPathComponent(filename)
        
        guard let data = UIImageJPEGRepresentation(self, 0.6) else {
            return false
        }
        
        try data.write(to: path)
        url = path
        return true
    }
    
}

func deleteFileAtURLs(urls: [URL]) throws {
    let fm = FileManager.default
    for url in urls {
        try fm.removeItem(at: url)
    }
}

