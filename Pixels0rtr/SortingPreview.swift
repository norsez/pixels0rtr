//
//  SortingPreview.swift
//  Pixels0rtr
//
//  Created by norsez on 12/5/16.
//  Copyright © 2016 Bluedot. All rights reserved.
//

import UIKit
import C4
class SortingPreview: NSObject {
    let MAX_THUMB_SIZE = 100
    func generatePreviews(with image: UIImage) -> [Image]?{
        let filter = GaussianBlur()
        guard let thumbnail = image.resize(byMaxPixels: MAX_THUMB_SIZE) else {
            print("failed creating thumbnail")
            return nil
        }
        
        let blurredThumb = Image(uiimage: thumbnail)
        blurredThumb.apply(filter)
        
        let pattern = PatternClassic()
        var previews = [Image]()
        for s in PixelSorterFactory.ALL_SORTERS {
            let param = SortParam(motionAmount: 0, sortAmount: 1, sorter: s, pattern:pattern)
            let preview = PixelSorting.sorted(image: blurredThumb, sortParam: param, progress: { (progress) in
                print("generting preview \(s.name) :\(progress)")
            })
            previews.append(preview)
        }
        return previews
    }
    
}
