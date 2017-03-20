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
    internal func initialize(withWidth width: Int, height: Int, sortParam: SortParam) {
        self.imageWidth = width
        self.imageHeight = height
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

class PatternStripe: AbstractSortPattern {
    
    var table = [[Bool]]()
    
    func scalePxForBase1600(value: Int) -> Int {
        let normalized =  fMap(value: Double(value), fromMin: 2, fromMax: 1600, toMin: 0, toMax: 1)
        let scaledValue = pow(normalized, 2)
        return max(Int(scaledValue * 1600), 2)
    }
    
    func roughnessDots(withDotsPerScanLine dotsPerScanLine: Int, roughnessAmount: Double) -> Int {
        
        let MIN_R = 2
        let LARGEST_SORT_WIDTH = 32
        let r = MIN_R + Int(Double(dotsPerScanLine)/(Double(LARGEST_SORT_WIDTH) * (roughnessAmount + 0.0001)))
        return r
        
    }
    var maxDotsToReset: Int {
        return Int(Double(self.imageWidth) * 0.1)
    }
    
    override func initialize(withWidth width: Int, height: Int, sortParam: SortParam) {
        super.initialize(withWidth: width, height: height, sortParam: sortParam)
        let scanLines = width
        let dotsPerScanLine = height
        
        //let MAX_DOTS_TO_RESET = self.maxDotsToReset;
        let numDotsToReset = 2 + Int(Double(self.maxDotsToReset) * sortParam.sortAmount) + Int(Double(width) * 0.1 * sortParam.motionAmount)
        
        let scanLinesToDuplicate = self.roughnessDots(withDotsPerScanLine: dotsPerScanLine, roughnessAmount: sortParam.roughnessAmount)
        
        
        Logger.log(" lines to dup: \(scanLinesToDuplicate)")
        Logger.log(" num dots to reset \(numDotsToReset)" )
        
        self.table = [[Bool]]()
        for _ in 0..<scanLines {
            self.table.append(Array<Bool>(repeating: false, count:dotsPerScanLine))
        }
        
        
        var sumNumDot = 0
        var sumDuplicatedScanLines = scanLinesToDuplicate
        var previousScanLineWithReset = -1
        
        for scan in 0..<scanLines {
            if (sumDuplicatedScanLines < scanLinesToDuplicate && previousScanLineWithReset != -1) {
                table[scan] = table[previousScanLineWithReset]
                sumDuplicatedScanLines = sumDuplicatedScanLines + 1;
            } else {
                //scan dots and find index to reset sort
                for dot in 0..<dotsPerScanLine {
                    if (sumNumDot < numDotsToReset) {
                        table[scan][dot] = false
                        sumNumDot = sumNumDot + 1
                    } else {
                        table[scan][dot] = true;
                        sumNumDot = Int(Double(numDotsToReset) * 0.5);
                        previousScanLineWithReset = scan
                    }
                }
                
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
            return "Stripe"
        }
    }
}

class PatternOffset: PatternStripe {
    
    override func roughnessDots(withDotsPerScanLine dotsPerScanLine: Int, roughnessAmount: Double) -> Int {
        
        let MAX_ROUGH = 16.0;
        let r = 2 + Int(MAX_ROUGH * roughnessAmount)
        return r
    }
    
    override var maxDotsToReset: Int {
        get {
            return Int(64 * 2.15)
        }
    }
    
    override var name: String {
        get {
            return "Offset"
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
