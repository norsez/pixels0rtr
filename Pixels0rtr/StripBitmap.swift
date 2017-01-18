//
//  StripBitmap.swift
//  Pixels0rtr
//
//  Created by norsez on 12/18/16.
//  Copyright © 2016 Bluedot. All rights reserved.
//

import UIKit

class ScanLineDrawer: NSObject {
    
    fileprivate let size: CGSize
    let context: CGContext?
    init(withCGSize size: CGSize) {
        self.size = size
        UIGraphicsBeginImageContextWithOptions(size, true, 1)
        self.context = UIGraphicsGetCurrentContext()
    }
    
    func draw(image: UIImage) {
        if let cgImage = image.cgImage {
            var rect = CGRect.zero
            rect.size = self.size
            context?.draw(cgImage, in: rect)
        }
    }
    
    func draw(strip: CGImage, index: Int) {
        var rect = CGRect.zero
        rect.origin = CGPoint(x:index, y: 0)
        rect.size = CGSize(width: 1, height: self.size.height)
        context?.draw(strip, in: rect)
    }
    
    func makeImage () -> UIImage? {
        if let cgImage = context?.makeImage().flatMap({ $0 }) {
            UIGraphicsEndImageContext()
            return UIImage(cgImage: cgImage)
        }else {
            return nil
        }
    }
    
}
