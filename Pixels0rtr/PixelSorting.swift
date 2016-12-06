//
//  PixelSorting.swift
//  Pixels0rtr
//
//  Created by Norsez Orankijanan on 11/30/2559 BE.
//  Copyright © 2559 Bluedot. All rights reserved.
//

import UIKit
import C4

struct SortParam {
    var motionAmount: Double = 0
    var sortAmount: Double = 0.5
    var sorter: PixelSorter
    var pattern: SortPattern
}

protocol PixelSorter {
    var name: String {get}
    func order(by color: Color, index: Double, totalColors: Int, sortParam: SortParam)->Double
}

class PixelSorterFactory {
    
    static let ALL_SORTERS: [PixelSorter] = [SorterBrightness(), SorterHue(), SorterSaturation(), SorterCenterSorted(), SorterIntervals()]
    
    static func sorter(with name: String) -> PixelSorter? {
        for s in ALL_SORTERS {
            if s.name == name {
                return s
            }
        }
        
        return nil
    }
    
    //#MARK: - singleton
    static let shared: PixelSorterFactory = {
        let instance = PixelSorterFactory()
        // setup code
        return instance
    }()

    
}

class SorterBrightness: PixelSorter {
    var name: String {
        get {
            return "Brightness"
        }
    }
    
    func order(by color: Color, index: Double, totalColors: Int, sortParam: SortParam)->Double {
        
        return color.brightness
    }
}


class SorterHue: PixelSorter {
    var name: String {
        get {
            return "Hue"
        }
    }
    
    func order(by color: Color, index: Double, totalColors: Int, sortParam: SortParam)->Double {
        return color.hue
    }
}

class SorterSaturation: PixelSorter {
    var name: String {
        get {
            return "Saturation"
        }
    }
    
    func order(by color: Color, index: Double, totalColors: Int, sortParam: SortParam)->Double {
        
        return color.saturation
    }
}

class SorterCenterSorted: PixelSorter {
    var name: String {
        get {
            return "Center Sorted"
        }
    }
    
    func order(by color: Color, index: Double, totalColors: Int, sortParam: SortParam)->Double {
        let t = sortParam.motionAmount * 0.4 + 0.01
        if (index < t ){
            return ((1 - index) * Double(totalColors)) - 2805.0
        }else if (index > 1 - t) {
            return (index * Double(totalColors)) + 2805.0
        }
        return color.brightness * 255
    }
}

class SorterIntervals: PixelSorter {
    var name: String {
        get {
            return "Intervals"
        }
    }
    
    func order(by color: Color, index: Double, totalColors: Int, sortParam: SortParam)->Double {
        let thres = 0.4
        if index <= thres {
            return index * Double(totalColors)
        }
        
        return map(color.brightness, min: 0, max: 1, toMin: thres * Double(totalColors), toMax: Double(totalColors))
    }
}
//MARK: quick sort
class PixelSorting: NSObject {
    
    static func sorted(image: Image, sortParam: SortParam, progress: ((Double)->Void)?) -> Image {
        let pattern = sortParam.pattern
        
        let toSort = pattern.colorArrays(of: image.cgImage, size: image.size)
        print("\(toSort.count) pieces to sort")
        var sortedArrays = [[Color]]()
        
        for index in 0..<toSort.count {
            var colors = toSort[index]
            sort(colors: &colors, sortIndex: index, sortParam: sortParam)
            sortedArrays.append(colors)
            if let p = progress {
                p(Double(index)/Double(toSort.count))
            }
        }
        let image = pattern.image(with: sortedArrays, size: image.size)
        return image
    }
    
    
    static fileprivate func sort(colors: inout [Color], sortIndex:  Int, sortParam: SortParam) {
        if colors.count == 0 {
            return
        }
        
        //to create pattern, divide array into pieces and sort them separately
        let unsortedPhases = sortPhases(withColors: colors, sortIndex: sortIndex, sortParam: sortParam)
        
        var sortedPhases = [[Color]]()
        for var phase in unsortedPhases {
            quicksort(WithColors: &phase, low: 0, high: phase.count - 1, sortParam: sortParam)
            sortedPhases.append(phase)
        }
        colors = combinedColors(withSortPhases: sortedPhases)
    }
    
    /**
     @return phases to sort defined by input sort pattern
     */
    static fileprivate func sortPhases(withColors colors: [Color], sortIndex: Int, sortParam: SortParam) -> [[Color]]{
        
        if colors.count < 2 {
            return [colors]
        }
        
        let pattern = sortParam.pattern
        
        var results = [[Color]]()
        var curCol = [Color]()
        for i in 0..<colors.count {
            if pattern.resetSubsortBlock(withIndex: i, sortIndex: sortIndex) {
                results.append(curCol)
                curCol = [colors[i]]
            }else {
                curCol.append(colors[i])
            }
        }
        results.append(curCol)
        return results
    }
    
    /**
     * reduce phases of colors back to a one dimensio array of colors
     **/
    static fileprivate func combinedColors(withSortPhases phases: [[Color]]) -> [Color] {
        return phases.reduce([], { (npr, phase) -> [Color] in
            var result = npr
            result.append(contentsOf: phase)
            return result
        })
    }

    
    static fileprivate func quicksort(WithColors colors : inout [Color], low: Int, high: Int, sortParam: SortParam){
        
        if colors.count == 0 {
            return
        }
        
        if low >= high {
            return
        }
        
        let pixelsort = sortParam.sorter
        
        let middle = Int(Double(low) + Double(high - low) * 0.5)
        let index_factor = Double(low)/Double(colors.count)
        let pivot = pixelsort.order(by: colors[middle], index: index_factor, totalColors: colors.count, sortParam: sortParam)
        
        var i = low, j = high;
        while i <= j {
            while pixelsort.order(by: colors[i], index: index_factor, totalColors: colors.count, sortParam: sortParam) < pivot{
                i = i + 1
            }
            while pixelsort.order(by: colors[j], index: index_factor, totalColors: colors.count, sortParam: sortParam) > pivot{
                j = j - 1
            }
            if i <= j {
                let temp = colors[i]
                colors[i] = colors[j]
                colors[j] = temp
                i = i+1
                j = j-1
            }
        }
        
        if (low < j) {
            quicksort(WithColors: &colors, low: low, high: j, sortParam: sortParam)
        }
        
        if (high > i) {
            quicksort(WithColors: &colors, low: i, high: high, sortParam: sortParam)
        }
        
    }
}
