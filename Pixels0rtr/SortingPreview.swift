//
//  SortingPreview.swift
//  Pixels0rtr
//
//  Created by norsez on 12/5/16.
//  Copyright © 2016 Bluedot. All rights reserved.
//

import UIKit
import C4
import CoreImage
class SortingPreview: NSObject {
    let MAX_THUMB_SIZE = 200
    var previews = [HorizontalSelectItem]()
    
    func generatePreviews(with image: UIImage) -> [HorizontalSelectItem]?{
        
        guard let thumbnail = image.resize(byMaxPixels: MAX_THUMB_SIZE) else {
            print("failed creating thumbnail")
            return nil
        }
        
        let blurredThumb = self.imageToSort(withImage: thumbnail)
        let pattern = PatternClassic()
        previews = [HorizontalSelectItem]()
        for s in PixelSorterFactory.ALL_SORTERS {
            guard let imageToSort = blurredThumb?.makeCopy() else {
                print ("can't copy original blurred image")
                continue
            }
            let param = SortParam(motionAmount: 0, sortAmount: 1, sorter: s, pattern:pattern)
            pattern.initialize(withWidth: Int(imageToSort.size.width), height: Int(imageToSort.size.height), sortParam: param)
            let preview = PixelSorting.sorted(image: Image(uiimage:imageToSort), sortParam: param, progress: { (progress) in
                //print("generting preview \(s.name) :\(progress)")
            })
            let previewItem = HorizontalSelectItem(image: preview.uiimage, title: s.name)
            previews.append(previewItem)
        }
        return self.previews
    }
    
    func imageToSort(withImage image: UIImage) -> UIImage?{
        guard let beginImage = CIImage(image:image) else {
            print("Can't get CIImage")
            return nil
        }
        
        guard let filter = CIFilter(name: "CIPixellate") else {
            print("can't get pixellate filter")
            return nil
        }
        
        filter.setValue(beginImage, forKey: kCIInputImageKey)
//        filter.setValue(CIVector(x:image.size.width * 0.9, y:image.size.height * 0.9), forKey: kCIInputCenterKey)
        filter.setValue(4, forKey: kCIInputScaleKey)
        guard let outputImage = filter.value(forKey: kCIOutputImageKey) as? CIImage else {
            print("can't get filter output")
            return nil
        }
        
        let context = CIContext(options: nil)
        let imageRef = context.createCGImage(filter.outputImage!, from: outputImage.extent)
        let result = UIImage(cgImage: imageRef!)
        return result
    }
    
    
}
