
//
//  UIView.swift
//  Pixels0rtr
//
//  Created by Norsez Orankijanan on 12/9/2559 BE.
//  Copyright © 2559 Bluedot. All rights reserved.
//

import UIKit

extension UIView {
    
    static func animatedPixelsortedImage(withImage image: UIImage, steps: Int) -> [UIImage] {
        var images = [UIImage]()
        images.append(image)
        let pattern = PatternClassic()
        let sorter = SorterBrightness()
        var sortParam = SortParam(motionAmount: 0, sortAmount: 0, sorter: sorter, pattern: pattern)
        sortParam.pattern.initialize(withWidth: Int(image.size.width), height: Int(image.size.height), sortParam: sortParam)
        
        for i in 0..<steps {
            let amount = Double(i)/Double(steps)
            sortParam.sortAmount = amount
            if let ciImage = PixelSorting.sorted(image: image, sortParam: sortParam, progress: {f in}) {
                let sortedImage = ciImage
                images.append(sortedImage)
            }
        }
        return images
    }
    
    static func animatedPixelsortedImageView(fromRect rect: CGRect, steps: Int) -> UIImageView?{
        let snapshot = UIScreen.main.snapshotView(afterScreenUpdates: false)
        if snapshot.bounds.contains(rect) == false {
            return nil
        }
        
        guard let toAnimate = UIImage.image(withView: snapshot, inRect: rect) else {
            return nil
        }
        
        let images = self.animatedPixelsortedImage(withImage: toAnimate, steps: steps)
        let animatedImage = UIImage.animatedImage(with: images, duration: 1)
        let imgView = UIImageView(image: animatedImage)
        imgView.frame = rect
        imgView.animationRepeatCount = 2
        imgView.animationDuration = 1
        return imgView
    }
    
}
