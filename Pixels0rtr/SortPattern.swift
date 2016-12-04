//
//  SortPattern.swift
//  Pixels0rtr
//
//  Created by Norsez Orankijanan on 11/30/2559 BE.
//  Copyright © 2559 Bluedot. All rights reserved.
//

import UIKit
import C4

enum SortOrientation {
    case horizontal, vertical
}

protocol SortPattern {
    var name: String {get}
    var sortOrientation: SortOrientation {get set}
    func initialize(withWidth width:Int, height: Int, amount: Float, motion: Float)
    func resetSubsortBlock(withIndex index: Int, sortIndex: Int) -> Bool
    func colorArrays(of cgimage: CGImage, size: Size) -> [[Color]]
    func image(with colorArrays: [[Color]], size: Size) -> Image
}

class AbstractSortPattern: SortPattern{
    internal func initialize(withWidth width: Int, height: Int, amount: Float, motion: Float) {
        
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
    
    func image(with colorArrays: [[Color]], size: Size) -> Image {
        var pixels = [Pixel]()
        for index in 0..<colorArrays.count {
            switch self.sortOrientation {
            case .horizontal:
                let parr = colorArrays[index].flatMap({ (c) -> Pixel? in
                    return Pixel(c)
                })
                pixels.append(contentsOf: parr)
            default:
                for col in 0..<Int(size.width) {
                    let col = colorArrays[col]
                    for w in 0..<Int(size.height) {
                        pixels.append(Pixel(col[w]))
                    }
                }
            }
        }
        return Image(pixels: pixels, size: size)
    }
    
//    func colorArrays(of image: Image) -> [[Color]] {
//        var results = [[Color]]()
//        switch self.sortOrientation {
//        case .horizontal:
//            for h in 0..<Int(image.height) {
//                let rect = CGRect(x: 0, y: h, width: Int(image.width), height: 1)
//                let c = image.colors(at: rect)
//                results.append(c)
//            }
//        default:
//            for w in 0..<Int(image.width) {
//                let rect = CGRect(x: w, y: 0, width: 1, height: Int(image.height))
//                let c = image.colors(at: rect)
//                results.append(c)
//            }
//        }
//        return results
//    }
    
    func colorArrays(of cgimage: CGImage, size: Size) -> [[Color]]{
        
        let imageProvider = cgimage.dataProvider
        let imageData = imageProvider?.data
        
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(imageData)
        
        var results = [[Color]]()
        let NUM_COMPS = Int(Double(cgimage.bitsPerPixel) / Double(cgimage.bitsPerComponent))
        let DATA_SIZE = Int(size.width)*Int(size.height) * NUM_COMPS
        
        switch self.sortOrientation {
        case .horizontal:
            var rowData = [Color]()
            for idx in stride(from: 0, to: DATA_SIZE, by: NUM_COMPS) {
                if idx > 0 && idx % (Int(size.width) * NUM_COMPS) == 0 {
                    results.append(rowData)
                    rowData = [Color]()
                }
                let c = Color(red: Double(data[idx + 1])/255.0,
                         green: Double(data[idx + 2])/255.0,
                         blue: Double(data[idx + 3])/255.0,
                         alpha: Double(data[idx])/255.0)
                rowData.append(c)
            }
            results.append(rowData)
            
        default:
            
            print("imple this")
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
    
    override func initialize(withWidth width: Int, height: Int, amount: Float, motion: Float) {
        resetRowIndexByCol = [Int]()
        let factor = 1.0/(amount + 0.00001);
        let _max: Float = 2.0 * factor;
        let _min: Float = 25.0 * factor;
        
        switch self.sortOrientation {
        case .vertical:
            for _ in 0..<width {
                let r = fRandom(min: Float(height)/_min, max: Float(height)/_max)
                let v = max(2.0, r) + motion * 25.0
                resetRowIndexByCol.append(Int(v))
            }
        default:
            for _ in 0..<height {
                let r = fRandom(min: Float(height)/_min, max: Float(height)/_max)
                let v = max(2.0, r) + motion * 25.0
                resetRowIndexByCol.append(Int(v))
            }
            
        }
        
    }
    
    override func resetSubsortBlock(withIndex index: Int, sortIndex: Int) -> Bool {
        return index % resetRowIndexByCol[sortIndex] == 0;
    }
}
