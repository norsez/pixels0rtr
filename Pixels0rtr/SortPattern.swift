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
    func resetSubsortBlock(withIndex index: Int, sortIndex: Int) -> Bool
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
    
    internal func resetSubsortBlock(withIndex index: Int, sortIndex: Int) -> Bool {
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
        
//        Logger.log("built image of size \(size)")
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
   
    
    override func initialize(withWidth width: Int, height: Int, sortParam: SortParam) {
        resetRowIndexByCol = [Int]()
        
        let c_sortAmount = pow(sortParam.sortAmount, 1.15)
        let c_roughness = pow(sortParam.roughnessAmount, 1.25)
        let factor = 1.0/(c_sortAmount + 0.00001);
        let _max = 1.1 * factor;
        let _min = 25.0 * factor;
        
        var lastValue: Int = 0
        
        let MIN_R = 1
        let MAX_R = Int(Double(sortParam.orientation == .horizontal ? height : width)/24.0)
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
    
    override func resetSubsortBlock(withIndex index: Int, sortIndex: Int) -> Bool {
        return index % resetRowIndexByCol[sortIndex] == 0;
    }
}

