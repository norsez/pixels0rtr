//
//  SortPattern.swift
//  Pixels0rtr
//
//  Created by Norsez Orankijanan on 11/30/2559 BE.
//  Copyright © 2559 Bluedot. All rights reserved.
//

import UIKit
import C4


enum SortOrientation: Int, CustomStringConvertible {
    case right, down, left, up
    
    var description: String {
        get {
            switch self {
            case .right:
                return "right"
            case .down:
                return "down"
            case .up:
                return "up"
            case .left:
                return "left"
            }
        }
    }
}



protocol SortPattern {
    var name: String {get}
    
    func initialize(withWidth width:Int, height: Int, sortParam: SortParam)
    func resetSubsortBlock(withIndex index: Int, sortIndex: Int, sortParam: SortParam) -> Bool
    func colorArrays(of cgimage: CGImage, size: CGSize, progress: (Float)->Void) -> [[SortColor]]
    func image(with colorArrays: [[SortColor]], size: CGSize, progress: (Float)->Void) -> Image
}

class AbstractSortPattern: SortPattern{
    
    var imageWidth = 0
    var imageHeight = 0
    var sortParam: SortParam?
    
    internal func initialize(withWidth width: Int, height: Int, sortParam: SortParam) {
        self.imageWidth = width
        self.imageHeight = height
        self.sortParam = sortParam
    }
    
    init() {
        
    }
    var name: String {
        get {
            return "Untitled"
        }
    }
    
    internal func resetSubsortBlock(withIndex index: Int, sortIndex: Int, sortParam: SortParam) -> Bool {
        return false
    }
    
    func image(with colorArrays: [[SortColor]], size: CGSize, progress: (Float)->Void) -> Image {
        var pixels = [Pixel]()
        for row in 0..<Int(size.height) {
            for colarr in colorArrays {
                pixels.append(colarr[row].C4Pixel)
            }
            progress(Float(row)/Float(size.height))
        }
        
        //Logger.log("built image of size \(size)")
        return Image(pixels: pixels, size: Size(size))
    }
    
    func colorArrays(of cgimage: CGImage, size: CGSize, progress: (Float)->Void) -> [[SortColor]]{
        
        let bitmap = Bitmap(img: cgimage)
        guard let correctedBitmapCGImage = bitmap.asCGImage else {
            Logger.log("can't create correct bitmap format")
            return []
        }
        let imageProvider = correctedBitmapCGImage.dataProvider
        let imageData = imageProvider?.data
        
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(imageData)
        
        var results = [[SortColor]]()
        let NUM_COMPS = 4 //know this from how bitmap object defines context
        //let DATA_SIZE = Int(size.width)*Int(size.height) * NUM_COMPS
        
        for x in 0..<Int(size.width) {
            var colorCols = [SortColor]()
            for y in 0..<Int(size.height) {
                let idx = (y * Int(size.width) + x) * NUM_COMPS
                let c = SortColor(withRed: data[idx + 1],
                                  green: data[idx + 2],
                                  blue: data[idx + 3],
                                  alpha: data[idx])
                colorCols.append(c)
            }
            
            
            progress (Float(x)/Float(size.width))
            
            results.append(colorCols)
        }
        
        return results
    }
}



class PatternClassic : AbstractSortPattern {
    var resetRowIndexByCol: [Int] = []
    
    override var name: String {
        get {
            return "Classic"
        }
    }
    
    fileprivate var maximumPhaseReset: Int {
        get {
            return 25
        }
    }
    
    fileprivate var largestSortWidth: Int {
        get {
            return 24
        }
    }
    
    override func initialize(withWidth width: Int, height: Int, sortParam: SortParam) {
        resetRowIndexByCol = [Int]()
        
        let c_sortAmount = pow(sortParam.sortAmount, 1.15)
        let c_roughness = pow(sortParam.roughnessAmount, 1.25)
        let factor = 1.0/(c_sortAmount + 0.00001);
        let _max = 1.1 * factor;
        let _min = Double(self.maximumPhaseReset) * factor;
        
        var lastValue: Int = 0
        
        let MIN_R = 1
        let MAX_R = Int(Double(width)/Double(self.largestSortWidth))
        let roughness = MIN_R + Int(Double(MAX_R) * c_roughness)
        
        Logger.log(" -- roughness:  \(roughness), sort amt: \(_min)-\(_max)")
        
        for i in 0..<width {
            
            if i % roughness != 0 {
                resetRowIndexByCol.append(lastValue)
            }else {
                let r = fRandom(min: Double(height)/_min, max: Double(height)/_max)
                let v = max(2.0, r) + (sortParam.motionAmount * 0.1 * Double(width))
                lastValue = Int(v)
                resetRowIndexByCol.append(lastValue)
            }
        }
    }
    override func resetSubsortBlock(withIndex index: Int, sortIndex: Int, sortParam: SortParam) -> Bool {
        return index % resetRowIndexByCol[sortIndex] == 0;
    }
}

class PatternOffset: AbstractSortPattern {
    
    var table = [[Bool]]()
    
    
    fileprivate func scaledIfNeeded(atPx: Int, fromMaxPx: Int, toMaxPx: Int) -> Int {
        if toMaxPx < atPx {
            return Int(fMap(value: Double(atPx), fromMin: 0, fromMax: Double(fromMaxPx), toMin: 0, toMax: Double(toMaxPx)))
        }
        return atPx
    }
    
    var rangeTimeToReset: (min: Int,max: Int) {
        get {
            return (min:1, max:4)
        }
    }
    
    var rangeTimetoDuplicate: (min: Int, max: Int) {
        get {
            return (min: 48, max: 512)
        }
    }
    
    override func initialize(withWidth width: Int, height: Int, sortParam: SortParam) {
        super.initialize(withWidth: width, height: height, sortParam: sortParam)
        let scanLines = width
        let dotsPerScanLine = height
        let range = self.rangeTimeToReset
        let t = fMap(value: sortParam.sortAmount, fromMin: 0.0, fromMax: 1.0, toMin:Double(range.min) , toMax: Double(range.max))
        let numDotsToReset = Int(Double(dotsPerScanLine) / t)
        
        let rdup = self.rangeTimetoDuplicate
        let td = fMap(value: sortParam.roughnessAmount, fromMin: 0.0, fromMax: 1.0, toMin:Double(rdup.min) , toMax: Double(rdup.max))
        var scanLinesToDuplicate = Int(Double(dotsPerScanLine) / td)
        scanLinesToDuplicate = self.scaledIfNeeded(atPx: scanLinesToDuplicate, fromMaxPx: Int(Double(dotsPerScanLine)/Double(rdup.max)), toMaxPx: dotsPerScanLine)
        
        Logger.log("wxh: \(width)x\(height)")
        Logger.log(" num dots to reset \(numDotsToReset), t:\(t)" )
        Logger.log(" lines to dup: \(scanLinesToDuplicate), td:\(td)")
       
        
        self.table = [[Bool]]()
        for _ in 0..<scanLines {
            self.table.append(Array<Bool>(repeating: false, count:dotsPerScanLine))
        }
        
        var sumNumDot = 0
        var sumDuplicatedScanLines = scanLinesToDuplicate
        //var previousScanLineWithReset = 0
        
        for scan in 0..<scanLines {
            if (sumDuplicatedScanLines < scanLinesToDuplicate) {
                table[scan] = table[scan-1]
                sumDuplicatedScanLines = sumDuplicatedScanLines + 1;
                continue
            } else {
                
                var dot = sumNumDot
                while dot < dotsPerScanLine {
                    table[scan][dot] = true
                    dot = dot.advanced(by: numDotsToReset)
                }
                sumNumDot =  dot - dotsPerScanLine
                
                //reset roughness
                sumDuplicatedScanLines = 0
            }
        }
    }
    
    override func resetSubsortBlock(withIndex index: Int, sortIndex: Int, sortParam: SortParam) -> Bool {
        return table[sortIndex][index]
    }
    
    override var name: String {
        get{
            return "Offset"
        }
    }
}

class PatternStripe: PatternOffset {
    

    
    override var name: String {
        get {
            return "Stripe"
        }
    }
    
    override var rangeTimeToReset: (min: Int,max: Int) {
        get {
            return (min:4, max:96)
        }
    }
    
    override var rangeTimetoDuplicate: (min: Int, max: Int) {
        get {
            return (min: 24, max: 1024)
        }
    }

    override func initialize(withWidth width: Int, height: Int, sortParam: SortParam) {
        super.initialize(withWidth: width, height: height, sortParam: sortParam)
        let scanLines = width
        let dotsPerScanLine = height
        let range = self.rangeTimeToReset
        let t = fMap(value: sortParam.sortAmount, fromMin: 0.0, fromMax: 1.0, toMin:Double(range.min) , toMax: Double(range.max))
        let numDotsToReset = Int(Double(dotsPerScanLine) / t)
        
        let scanLinesToDuplicate = 2 + Int((Double(scanLines - 4) * sortParam.roughnessAmount))
        
        Logger.log("wxh: \(width)x\(height)")
        Logger.log(" num dots to reset \(numDotsToReset), t:\(t)" )
        Logger.log(" lines to dup: \(scanLinesToDuplicate)")
        
        
        self.table = [[Bool]]()
        for _ in 0..<scanLines {
            self.table.append(Array<Bool>(repeating: false, count:dotsPerScanLine))
        }
        
        
        var sumDuplicatedScanLines = scanLinesToDuplicate
        //var previousScanLineWithReset = 0
        
        for scan in 0..<scanLines {
            if (sumDuplicatedScanLines < scanLinesToDuplicate) {
                table[scan] = table[scan-1]
                sumDuplicatedScanLines = sumDuplicatedScanLines + 1;
            } else {
                var dot = 0
                while dot < dotsPerScanLine {
                    table[scan][dot] = true
                    dot = dot.advanced(by: numDotsToReset)
                }
                sumDuplicatedScanLines = 0
            }
        }
    }

}



class PatternClean: PatternClassic {
    
    override var name: String {
        get {
            return "Clean"
        }
    }
    
    fileprivate override var maximumPhaseReset: Int {
        get {
            return 4
        }
    }
    
    fileprivate override var largestSortWidth: Int {
        get {
            return 2
        }
    }
    
    override func resetSubsortBlock(withIndex index: Int, sortIndex: Int, sortParam: SortParam) -> Bool {
        if sortParam.roughnessAmount < 0.025 {
            return false
        }else {
            return super.resetSubsortBlock(withIndex: index, sortIndex: sortIndex, sortParam: sortParam)
        }
    }
}
