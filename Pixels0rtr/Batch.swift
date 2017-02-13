//
//  Batch.swift
//  Pixels0rtr
//
//  Created by norsez on 2/11/17.
//  Copyright © 2017 Bluedot. All rights reserved.
//

import UIKit

class Batch: NSObject {
    
    func renderFrom(point1: SortParam, toPoint2 point2: SortParam, frames: Int, image: UIImage, progress: (Float)->Void, aborted: @escaping () -> Bool, completion:([UIImage])->Void) {
        var steps = [SortParam]()
        steps.append(point1)
        for f in 0..<frames {
            var sp = point1
            let step = Double(f)/Double(frames)
            sp.sortAmount = fMap(value: step, fromMin: 0, fromMax: 1, toMin: point1.sortAmount, toMax: point2.sortAmount)
            sp.roughnessAmount = fMap(value: step, fromMin: 0, fromMax: 1, toMin: point1.roughnessAmount, toMax: point2.roughnessAmount)
            sp.motionAmount = fMap(value: step, fromMin: 0, fromMax: 1, toMin: point1.motionAmount, toMax: point2.motionAmount)
            sp.blackThreshold = UInt8(fMap(value: step, fromMin: 0, fromMax: 1, toMin: Double(point1.blackThreshold), toMax: Double(point2.blackThreshold)))
            sp.whiteThreshold = UInt8(fMap(value: step, fromMin: 0, fromMax: 1, toMin: Double(point1.whiteThreshold), toMax: Double(point2.whiteThreshold)))
            steps.append(sp)
        }
        steps.append(point2)
        
        Logger.log("steps: \(steps.count) start…")
        
        var outputs = [UIImage]()
        var doneCount = 0
        for sp in steps {
            
            if aborted() {
                break
            }
            
            let ps = PixelSorting(withSortParam: sp, imageToSort: image)
            ps.start(withProgress: progress, aborted: aborted, completion: { (image, stats) in
                if let output = image {
                    outputs.append(output)
                }
                
                doneCount = doneCount + 1
                Logger.log("done: \(doneCount)/\(steps.count)")
            })
            
        }
        
        completion(outputs)
    }
    
    //#MARK: - singleton
    static let shared: Batch = {
        let instance = Batch()
        // setup code
        return instance
    }()

}
