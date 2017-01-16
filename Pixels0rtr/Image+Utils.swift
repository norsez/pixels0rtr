//
//  Image+Utils.swift
//  Pixels0rtr
//
//  Created by norsez on 12/6/16.
//  Copyright © 2016 Bluedot. All rights reserved.
//

import UIKit
import CoreImage

extension UIImage {
    
    
    
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
    
    func scanLine(atIndex index: Int, orientation: SortOrientation) -> CGImage?{
        var rect = CGRect.zero
        switch orientation {
        case .horizontal:
            rect.origin = CGPoint(x:0, y: index)
            rect.size = CGSize(width: self.size.width, height: 1)
        default:
            rect.origin = CGPoint(x:index, y: 0)
            rect.size = CGSize(width: 1, height: self.size.height)
        }
        return self.cgImage?.cropping(to: rect)
        
    }
    
    func upsideDown () -> UIImage{
        var transform: CGAffineTransform = CGAffineTransform.identity
        transform = transform.translatedBy(x: size.width, y: size.height)
        transform = transform.rotated(by: CGFloat(M_PI))
        transform = transform.translatedBy(x: size.width, y: 0)
        transform = transform.scaledBy(x: -1, y: 1)
        
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
//            return self.image(withRotation: .m_pi_2)
//        }
    }
    
    
    enum ImageRotation: Int {
        case m_0_pi, m_pi_2, m_pi, m_3_pi_2
    }
    
    func image(withRotation rotation: ImageRotation) -> UIImage {
        
        var tf = CGAffineTransform.identity
        let LARGEST_SIZE = CGFloat(max(self.size.width, self.size.height))
        let DELTA_WIDTH = LARGEST_SIZE - self.size.width
        let DELTA_HEIGHT = LARGEST_SIZE - self.size.height
        
        switch rotation {
        case .m_0_pi:
            tf = tf.translatedBy(x: DELTA_WIDTH, y: DELTA_HEIGHT)
        case .m_pi_2:
            tf = tf.rotated(by: CGFloat(M_PI_2))
            tf = tf.translatedBy(x: 0, y: -self.size.height)
        case .m_pi:
            tf = tf.rotated(by: CGFloat(M_PI))
            tf = tf.translatedBy(x: -self.size.height-DELTA_HEIGHT, y: -self.size.width)
        case .m_3_pi_2:
            tf = tf.rotated(by: CGFloat(3 * M_PI_2))
            tf = tf.translatedBy(x: -self.size.width, y: 0)
        }
        
        let cgImage = self.cgImage!
        
        let context = CGContext.init(data: nil, width:Int(LARGEST_SIZE), height:Int(LARGEST_SIZE), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: cgImage.colorSpace!, bitmapInfo: cgImage.bitmapInfo.rawValue)!
        context.concatenate(tf)
        context.draw(cgImage, in: CGRect(x:0,y:0,width:cgImage.width, height: cgImage.height))
        
        var resultImage = context.makeImage()!
        
        var cropRect = CGRect.zero
        switch rotation {
        case .m_0_pi, .m_pi:
            cropRect.size = self.size
        case .m_pi_2, .m_3_pi_2:
            cropRect.size = CGSize(width: self.size.height, height: self.size.width)
        }
        resultImage = resultImage.cropping(to: cropRect)!
        
        return UIImage(cgImage: resultImage)
        
    }

    
}

