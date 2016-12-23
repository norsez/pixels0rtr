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
    let MAX_THUMB_SIZE = 150
    var previews = [String:HorizontalSelectItem]()
    
    
    func title(ofSortParam sp: SortParam) -> String {
        return "\(sp.sorter.name) - \(sp.pattern.name)"
    }
    
    func previewImage(withSortParam sp: SortParam) -> UIImage?{
        let title = self.title(ofSortParam: sp)
        if let item = self.previews[title] {
            return item.image
        }else {
            return nil
        }
    }
    
    func updatePreviewImage(withImage image: UIImage, sortParam sp: SortParam) {
        let title = "\(sp.sorter.name) - \(sp.pattern.name)"
        if let item = self.previews[title] {
            var updatedItem = item
            updatedItem.image = image
            self.previews[title] = updatedItem
        }else {
            assert(false, "can't find preview item")
        }
    }
    
    func generatePreviews(with image: UIImage, sortParam sp: SortParam, progress: ((Float)->Void)? = nil) {
        
        guard let thumbnail = image.resize(byMaxPixels: MAX_THUMB_SIZE) else {
            Logger.log("failed creating thumbnail")
            return
        }
        
        let blurredThumb = thumbnail
        
        previews = [String:HorizontalSelectItem]()
        
        
        
        for var pattern in ALL_SORT_PATTERNS {
            for s in ALL_SORTERS {
                let imageToSort = blurredThumb
                
                var param = SortParam(roughness: sp.roughnessAmount, sortAmount: sp.sortAmount, sorter: s, pattern:pattern, maxPixels:.px600)
                param.orientation = sp.orientation
                
                pattern.initialize(withWidth: Int(imageToSort.size.width), height: Int(imageToSort.size.height), sortParam: param)
                
                guard let preview = PixelSorting.sorted(image: imageToSort, sortParam: param, progress: { (v) in
                    if let p = progress {
                        p(Float(v))
                    }
                }).output else {
                    continue
                }
                
                let title = self.title(ofSortParam: param)
                let previewItem = HorizontalSelectItem(image: preview, title: title)
                previews[title] = previewItem
                
            }
        }
    }
    
    func imageToSort(withImage image: UIImage) -> UIImage?{
        guard let beginImage = CIImage(image:image) else {
            Logger.log("Can't get CIImage")
            return nil
        }
        
        guard let filter = CIFilter(name: "CIPixellate") else {
            Logger.log("can't get pixellate filter")
            return nil
        }
        
        filter.setValue(beginImage, forKey: kCIInputImageKey)
        //filter.setValue(CIVector(x:image.size.width * 0.9, y:image.size.height * 0.9), forKey: kCIInputCenterKey)
        filter.setValue(Double(beginImage.extent.width)  * 0.05, forKey: kCIInputScaleKey)
        guard let outputImage = filter.value(forKey: kCIOutputImageKey) as? CIImage else {
            Logger.log("can't get filter output")
            return nil
        }
        
        let context = CIContext(options: nil)
        let imageRef = context.createCGImage(filter.outputImage!, from: outputImage.extent)
        let result = UIImage(cgImage: imageRef!)
        return result
    }
    
    
}
