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
        
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)
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
    
    func imageStrip(atIndex index: Int, orientation: SortOrientation) -> CGImage?{
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
    
}
