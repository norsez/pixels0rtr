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
    let PREVIEW_RATIO = 0.158
    var previews = [String:HorizontalSelectItem]()
    var valueFormatter: NumberFormatter
    
    var isRunningPreview = false
    
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
     func previewImage(withSortParam sp: SortParam) -> UIImage?{
        let title = self.title(ofSortParam: sp)
        if let item = self.previews[title] {
            return item.image
        }else {
            return nil
        }
    }
    
    func cancelRunningPreview () {
        self.isRunningPreview = false
    }
    
    /**
     create preview using full output size but limit to sortRect in sortParam
     */
    func updatePreview(forImage image:UIImage, withSortParam sp: SortParam, loupeOrigin: XYValue, progress: ((Float)->Void)?, completion: ((UIImage?, CGRect?)->Void)?) {
        
        var previewSortParam = sp
        previewSortParam.orientation = .down
        
        guard let imageToSort = image.resize(toFitMaxPixels: previewSortParam.maxPixels) else {
            Logger.log("failed to resize to fix \(previewSortParam.maxPixels)")
            return
        }
        let sortSize = CGFloat(min(imageToSort.size.width, imageToSort.size.height) * CGFloat(PREVIEW_RATIO))
        Logger.log("preview sort size: \(sortSize)")
        let sortRect = CGRect(x: CGFloat(loupeOrigin.x * imageToSort.size.width),
                              y: CGFloat(loupeOrigin.y * imageToSort.size.height),
                              width: sortSize,
                              height: sortSize
        )
        previewSortParam.sortRect = sortRect
        
        let ps = PixelSorting(withSortParam: previewSortParam, imageToSort: imageToSort)
        
        self.isRunningPreview = true
        
        ps.start(withProgress: { (v) in
            if let p = progress {
                p(Float(v))
            }
        }, aborted: { () -> Bool in
            
            return self.isRunningPreview == false
        }) { (image, stats) in
            
            if let c = completion {
                
                if let pv = image,
                    let cgImage = pv.cgImage,
                    let sr = previewSortParam.sortRect {
                    if let cropped = cgImage.cropping(to: sr),
                        let originalCGImage = imageToSort.cgImage {
                        let croppedImage = UIImage(cgImage: cropped)
                        let rotatedCropped = croppedImage.rotated(toSortOrientation: sp.orientation)
                        
                        if let context = CGContext.init(data: nil, width: originalCGImage.width, height: originalCGImage.height, bitsPerComponent: originalCGImage.bitsPerComponent, bytesPerRow: originalCGImage.bytesPerRow, space: originalCGImage.colorSpace!, bitmapInfo: originalCGImage.bitmapInfo.rawValue),
                            let rcgIage = rotatedCropped.cgImage {
                            var orect = CGRect.zero
                            orect.size = imageToSort.size
                            context.draw(originalCGImage, in: orect)
                            orect = sortRect
                            var flipTf = CGAffineTransform.identity
                            flipTf = flipTf.translatedBy(x: 0, y: imageToSort.size.height)
                            flipTf = flipTf.scaledBy(x: 1, y: -1)
                            orect = orect.applying(flipTf)
                            context.draw(rcgIage, in: orect)
                            if let result = context.makeImage() {
                                let resultImage = UIImage(cgImage: result)
                                c(resultImage, sortRect)
                            }
                        }
                    }
                }
                c(nil, sortRect)
            }
            self.isRunningPreview = false
            
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
    
}


class SamplePreviewEngine {
    var lastParams = [SortParam]()
    var lastImages = [UIImage]()
    
    var sampleSortParams: [SortParam] {
        get {
            
            var results = [SortParam]()
            
            let MORE_ :[String] = [PatternClassic(), PatternClean() ].flatMap { (p) -> String? in
                return p.name
            }
            
            for pattern in ALL_SORT_PATTERNS {
                for sorter in ALL_SORTERS {
                    
                    let VARIATIONS = MORE_.contains(pattern.name) ? 3 : 1
                    
                    for _ in 0..<VARIATIONS {
                        var sp = SortParam.randomize()
                        sp.pattern = pattern
                        sp.sorter = sorter
                        results.append(sp)
                    }
                }
            }
            return results
        }
    }
    
    func randomizedParams(withParams params: [SortParam], count: Int) -> [SortParam] {
        let MAX = min(params.count, count)
        var results = [SortParam]()
        var allparams = params
        while results.count < MAX {
            let idx = Int(arc4random_uniform(UInt32(allparams.count - 1)))
            let e = allparams[idx]
            results.append(e)
            allparams.remove(at: idx)
        }
        
        return results
    }
    
    func createRandomPreviews(count: Int, forImage image:UIImage, progress:@escaping (UIImage, SortParam, Double)->Void, aborted: @escaping ()->Bool, completion:([UIImage]?,[SortParam]?)->Void) {
        
        var params = [SortParam]()
        params.append(contentsOf: self.sampleSortParams)
        params = randomizedParams(withParams: params, count: count)
        
        let PREVIEW_SIZE = 150
        guard let imageToSort = image.resize(byMaxPixels: PREVIEW_SIZE) else {
            Logger.log("can't resize image")
            completion(nil,nil)
            return
        }
        
        var resultImages = [UIImage]()
        var imageCount = 0
        for sp in params {
            let p = PixelSorting(withSortParam: sp, imageToSort: imageToSort)
            p.start(withProgress: { (progress) in
                //
            }, aborted: aborted,
               completion: { (image, stats) in
                if let result = image {
                    resultImages.append(result)
                    let progressValue = Double(imageCount + 1)/Double(params.count)
                    progress(result, sp, progressValue )
                    
                }
                imageCount = imageCount.advanced(by: 1)
            })
        }
        self.lastImages = resultImages
        self.lastParams = params
        completion(resultImages,params)
    }
    
    //#MARK: - singleton
    static let shared: SamplePreviewEngine = {
        let instance = SamplePreviewEngine()
        // setup code
        return instance
    }()

}
