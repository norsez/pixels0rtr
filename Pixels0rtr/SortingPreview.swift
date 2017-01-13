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

struct PreviewParam {
    let image: UIImage
    let sortParam: SortParam
    let originX: Double //0..1
    let originY: Double //0..1
    let previewSize: Int
}

class SortingPreview: NSObject {
    let MAX_THUMB_SIZE = 250
    var previews = [String:HorizontalSelectItem]()
    var valueFormatter: NumberFormatter
    
    override init() {
        
        self.valueFormatter = NumberFormatter()
        self.valueFormatter.numberStyle = .decimal
        self.valueFormatter.maximumIntegerDigits = 1
        self.valueFormatter.minimumFractionDigits = 1
        self.valueFormatter.minimumFractionDigits = 2
        self.valueFormatter.maximumFractionDigits = 2
        
    }
    
    func title(ofSortParam sp: SortParam) -> String {
        
        let sa = self.valueFormatter.string(from: NSNumber(value:sp.sortAmount))!
        let ra = self.valueFormatter.string(from: NSNumber(value:sp.roughnessAmount))!
        let oa = sp.orientation.description
        
        return "\(sp.sorter.name) - \(sp.pattern.name) [\(sa),\(ra)] - \(oa)"
    }
    
    func clearPreviews() {
        self.previews.removeAll()
    }
    
    func createPreview(withParam pp: PreviewParam, progress: ((Float)->Void)?, completion:@escaping (UIImage?)->Void) {
        
        var correctSizeImage = pp.image
        if pp.sortParam.maxPixels != .pxTrueSize {
            if let csi = correctSizeImage.resize(byMaxPixels: pp.sortParam.maxPixels.pixels) {
                correctSizeImage = csi
            }else {
                completion(nil)
                Logger.log("can't generate image for size \(pp.sortParam.maxPixels)")
                return
            }
        }
        
        let cropRect = CGRect(x: pp.originX * Double(correctSizeImage.size.width),
                              y: pp.originY * Double(correctSizeImage.size.height),
                              width: Double(pp.previewSize),
                              height: Double(pp.previewSize)
                              );
        
        guard let croppedCGImage = correctSizeImage.cgImage?.cropping(to: cropRect) else {
            completion(nil)
            Logger.log("can't crop image to create preview")
            return
        }
        
        let croppedImage = UIImage(cgImage: croppedCGImage)
        
        self.updatePreview(forImage: croppedImage, withSortParam: pp.sortParam, progress: progress, completion: completion)
        
    }
    
    func previewImage(withSortParam sp: SortParam) -> UIImage?{
        let title = self.title(ofSortParam: sp)
        if let item = self.previews[title] {
            return item.image
        }else {
            return nil
        }
    }
    
    func updatePreview(forImage image:UIImage, withSortParam sp: SortParam, progress: ((Float)->Void)?, completion: ((UIImage?)->Void)?) {
        
//        if let existing = self.previewImage(withSortParam: sp),
//            let c = completion {
//            c(existing)
//            return
//        }
        
        guard let imageToSort = image.resize(byMaxPixels: MAX_THUMB_SIZE) else {
            Logger.log("failed creating thumbnail")
            return
        }
        
        sp.pattern.initialize(withWidth: Int(imageToSort.size.width), height: Int(imageToSort.size.height), sortParam: sp)
        
        guard let preview = PixelSorting.sorted(image: imageToSort, sortParam: sp, progress: { (v) in
            if let p = progress {
                p(Float(v))
            }
            
        }).output else {
            if let c = completion {
                c(nil)
            }
            return
        }
        
        let title = self.title(ofSortParam: sp)
        let previewItem = HorizontalSelectItem(image: preview, title: title)
        previews[title] = previewItem
        if let c = completion {
            c(preview)
        }
    }
    
    /**
     replace a preview in cache with the input image
     */
    func updatePreviewImage(withImage image: UIImage, forSortParam sp: SortParam) {
        let title = self.title(ofSortParam: sp)
        if let item = self.previews[title] {
            var updatedItem = item
            updatedItem.image = image
            self.previews[title] = updatedItem
        }else {
            assert(false, "can't find preview item")
        }
    }
    
    /**
     generate previews for all available pattern and sort type
     */
    func generatePreviews(with image: UIImage, sortParam sp: SortParam, progress: ((Float)->Void)? = nil) {
        
        guard let thumbnail = image.resize(byMaxPixels: MAX_THUMB_SIZE) else {
            Logger.log("failed creating thumbnail")
            return
        }
        
        let blurredThumb = thumbnail
        
        previews = [String:HorizontalSelectItem]()
                
        for pattern in ALL_SORT_PATTERNS {
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
    
//    func imageToSort(withImage image: UIImage) -> UIImage?{
//        guard let beginImage = CIImage(image:image) else {
//            Logger.log("Can't get CIImage")
//            return nil
//        }
//        
//        guard let filter = CIFilter(name: "CIPixellate") else {
//            Logger.log("can't get pixellate filter")
//            return nil
//        }
//        
//        filter.setValue(beginImage, forKey: kCIInputImageKey)
//        //filter.setValue(CIVector(x:image.size.width * 0.9, y:image.size.height * 0.9), forKey: kCIInputCenterKey)
//        filter.setValue(Double(beginImage.extent.width)  * 0.05, forKey: kCIInputScaleKey)
//        guard let outputImage = filter.value(forKey: kCIOutputImageKey) as? CIImage else {
//            Logger.log("can't get filter output")
//            return nil
//        }
//        
//        let context = CIContext(options: nil)
//        let imageRef = context.createCGImage(filter.outputImage!, from: outputImage.extent)
//        let result = UIImage(cgImage: imageRef!)
//        return result
//    }
    
    
}
