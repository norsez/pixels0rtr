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
    case horizontal, vertical
    
    var description: String {
        get {
            switch self {
            case .horizontal:
                return "Horizontal"
            default:
                return "Vertical"
            }
        }
    }
}



protocol SortPattern {
    var name: String {get}
    
    func initialize(withWidth width:Int, height: Int, sortParam: SortParam)
    func resetSubsortBlock(withIndex index: Int, sortIndex: Int, sortParam: SortParam) -> Bool
    func colorArrays(of cgimage: CGImage, size: CGSize, sortOrientation: SortOrientation, progress: (Float)->Void) -> [[SortColor]]
    func image(with colorArrays: [[SortColor]], size: CGSize, sortOrientation: SortOrientation, progress: (Float)->Void) -> Image
}

class AbstractSortPattern: SortPattern{
    internal func initialize(withWidth width: Int, height: Int, sortParam: SortParam) {
        
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
    
    func image(with colorArrays: [[SortColor]], size: CGSize, sortOrientation: SortOrientation, progress: (Float)->Void) -> Image {
        var pixels = [Pixel]()
        
            switch sortOrientation {
            case .horizontal:
                for index in 0..<colorArrays.count {
                    let parr = colorArrays[index].flatMap({ (sortColor) -> Pixel? in
                        return sortColor.C4Pixel
                    })
                    pixels.append(contentsOf: parr)
                    progress(Float(index)/Float(colorArrays.count))
                }
            default:
                for row in 0..<Int(size.height) {
                    for colarr in colorArrays {
                        pixels.append(colarr[row].C4Pixel)
                    }
                    progress(Float(row)/Float(size.height))
                }
            }
        
        //Logger.log("built image of size \(size)")
        return Image(pixels: pixels, size: Size(size))
    }
        
    func colorArrays(of cgimage: CGImage, size: CGSize, sortOrientation: SortOrientation, progress: (Float)->Void) -> [[SortColor]]{
        
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
        let DATA_SIZE = Int(size.width)*Int(size.height) * NUM_COMPS
        
        switch sortOrientation {
        case .horizontal:
            var rowData = [SortColor]()
            for idx in stride(from: 0, to: DATA_SIZE, by: NUM_COMPS) {
                if idx > 0 && idx % (Int(size.width) * NUM_COMPS) == 0 {
                    results.append(rowData)
                    rowData = [SortColor]()
                }
                let c = SortColor(withRed: data[idx + 1],
                         green: data[idx + 2],
                         blue: data[idx + 3],
                         alpha: data[idx])
                rowData.append(c)
                progress(Float(idx)/Float(DATA_SIZE))
                
            }
            results.append(rowData)
            
        default:
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
        let MAX_R = Int(Double(sortParam.orientation == .horizontal ? height : width)/Double(self.largestSortWidth))
        let roughness = MIN_R + Int(Double(MAX_R) * c_roughness)
        
        Logger.log(" -- roughness:  \(roughness), sort amt: \(_min)-\(_max)")
        
        switch sortParam.orientation {
        case .vertical:
            for i in 0..<width {
                
                if i % roughness != 0 {
                    resetRowIndexByCol.append(lastValue)
                }else {
                    let r = fRandom(min: Double(height)/_min, max: Double(height)/_max)
                    let v = max(2.0, r) + sortParam.motionAmount * 25.0
                    lastValue = Int(v)
                    resetRowIndexByCol.append(lastValue)
                    
                }
            }
        default:
            
            for i in 0..<height {
                
                if i % roughness != 0 {
                    resetRowIndexByCol.append(lastValue)
                }else {
                    let r = fRandom(min: Double(width)/_min, max: Double(width)/_max)
                    let v = max(2.0, r) + sortParam.motionAmount * 25.0
                    lastValue = Int(v)
                    resetRowIndexByCol.append(lastValue)
                }
            }
            
        }
        
    }
    
    override func resetSubsortBlock(withIndex index: Int, sortIndex: Int, sortParam: SortParam) -> Bool {
        return index % resetRowIndexByCol[sortIndex] == 0;
    }
}

class PatternOffset: AbstractSortPattern {
    
    var table = [[Bool]]()
    
    func scalePxForBase1600(value: Int) -> Int {
        let normalized =  fMap(value: Double(value), fromMin: 2, fromMax: 1600, toMin: 0, toMax: 1)
        let scaledValue = pow(normalized, 2)
        return max(Int(scaledValue * 1600), 2)
    }
    
    override func initialize(withWidth width: Int, height: Int, sortParam: SortParam) {
        super.initialize(withWidth: width, height: height, sortParam: sortParam)
        let scanLines = sortParam.orientation == .vertical ? width : height
        let dotsPerScanLine = sortParam.orientation == .vertical ? height : width
        
        //amount is how less frequently sort gets a reset block
        let RESET_K_1600p = 0.5
        let resetFactor:Double = RESET_K_1600p * Double(scanLines) / 1600.0
        let MAX_RESET_FACTOR = Double(scanLines) * resetFactor
        let pixelsPerReset = 1 + Int(sortParam.sortAmount * MAX_RESET_FACTOR)
        
        let ROUGH_K_1600p = 0.0156
        let roughFactor: Double = ROUGH_K_1600p * Double(scanLines) / 1600.0
        let MAX_ROUGH_DOTS = Double(dotsPerScanLine) * roughFactor
        let dots_per_rough = 2 + Int(sortParam.roughnessAmount * MAX_ROUGH_DOTS)
        
        
        Logger.log("cols per rough:\(dots_per_rough), pixelsPerReset: \(pixelsPerReset)")
        
        var sumDist: Int = 0
        var prevRowWithReset = 0
        
        self.table = [[Bool]]()
        for _ in 0..<scanLines {
            let colValues = Array(repeating: false, count: dotsPerScanLine)
            self.table.append(colValues)
        }
        
        for scan in 0..<scanLines {
            for dot in 0..<dotsPerScanLine {
                
                let mustReset = sumDist > pixelsPerReset
                
                if mustReset {
                    sumDist = 0
                    
                }else {
                    sumDist = sumDist + 1
                }
               
                if (mustReset) {
                    table[scan][dot] = true
                }else {
                    if (dot % dots_per_rough != 0 && scan > 0) {
                        table[scan][dot] = table[prevRowWithReset][dot]
                        prevRowWithReset = scan
                    }else  {
                        table[scan][dot] = false
                    }
                }
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
