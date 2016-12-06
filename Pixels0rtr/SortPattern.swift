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
    var sortOrientation: SortOrientation {get set}
    func initialize(withWidth width:Int, height: Int, sortParam: SortParam)
    func resetSubsortBlock(withIndex index: Int, sortIndex: Int) -> Bool
    func colorArrays(of cgimage: CGImage, size: CGSize) -> [[SortColor]]
    func image(with colorArrays: [[SortColor]], size: CGSize) -> Image
}

class AbstractSortPattern: SortPattern{
    internal func initialize(withWidth width: Int, height: Int, sortParam: SortParam) {
        
    }

    var sortOrientation: SortOrientation = .horizontal
    
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
    
    func image(with colorArrays: [[SortColor]], size: CGSize) -> Image {
        var pixels = [Pixel]()
        for index in 0..<colorArrays.count {
            switch self.sortOrientation {
            case .horizontal:
                let parr = colorArrays[index].flatMap({ (sortColor) -> Pixel? in
                    let c = sortColor.C4Color
                    return Pixel(c)
                })
                pixels.append(contentsOf: parr)
            default:
                for col in 0..<Int(size.width) {
                    let col = colorArrays[col]
                    for w in 0..<Int(size.height) {
                        pixels.append(Pixel(col[w].C4Color))
                    }
                }
            }
        }
        return Image(pixels: pixels, size: Size(size))
    }
        
    func colorArrays(of cgimage: CGImage, size: CGSize) -> [[SortColor]]{
        
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
        
        switch self.sortOrientation {
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
            }
            results.append(rowData)
            
        default:
            
            Logger.log("imple this")
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
        let factor = 1.0/(sortParam.sortAmount + 0.00001);
        let _max = 2.0 * factor;
        let _min = 25.0 * factor;
        
        switch self.sortOrientation {
        case .vertical:
            for _ in 0..<width {
                let r = fRandom(min: Double(height)/_min, max: Double(height)/_max)
                let v = max(2.0, r) + sortParam.motionAmount * 25.0
                resetRowIndexByCol.append(Int(v))
            }
        default:
            for _ in 0..<height {
                let r = fRandom(min: Double(width)/_min, max: Double(width)/_max)
                let v = max(2.0, r) + sortParam.motionAmount * 25.0
                resetRowIndexByCol.append(Int(v))
            }
            
        }
        
    }
    
    override func resetSubsortBlock(withIndex index: Int, sortIndex: Int) -> Bool {
        return index % resetRowIndexByCol[sortIndex] == 0;
    }
}
