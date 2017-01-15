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
    let context: CGContext
    let orientation: SortOrientation
    init(withCGSize size: CGSize, orientation: SortOrientation) {
        self.size = size
        UIGraphicsBeginImageContextWithOptions(size, true, 1)
        self.context = UIGraphicsGetCurrentContext()!
        self.orientation = orientation
    }
    
    func draw(strip: CGImage, index: Int) {
        var rect = CGRect.zero
        switch self.orientation {
        case .horizontal:
            rect.origin = CGPoint(x:0, y: index)
            rect.size = CGSize(width: self.size.width, height: 1)
        default:
            rect.origin = CGPoint(x:index, y: 0)
            rect.size = CGSize(width: 1, height: self.size.height)
        }
        
        context.draw(strip, in: rect)
    }
    
    func makeImage () -> UIImage? {
        let cgImage = context.makeImage().flatMap { $0 }!
        UIGraphicsEndImageContext()
        return UIImage(cgImage: cgImage)
    }
}
