//
//  PixelSorting.swift
//  Pixels0rtr
//
//  Created by Norsez Orankijanan on 11/30/2559 BE.
//  Copyright © 2559 Bluedot. All rights reserved.
//

import UIKit
import C4

protocol PixelSorter {
    var name: String {get}
    func order(by color: Color, index: Float, totalColors: Int)->Double
}

class SorterBrightness: PixelSorter {
    var name: String {
        get {
            return "Brightness"
        }
    }
    
    func order(by color: Color, index: Float, totalColors: Int)->Double {
        
        return color.brightness
    }
}

class PixelSorting: NSObject {
    
    static func sorted(image: Image, pattern: SortPattern, sorter: PixelSorter, progress: ((Float)->Void)?) -> Image {
        let toSort = pattern.colorArrays(of: image.cgImage, size: image.size)
        print("\(toSort.count) pieces to sort")
        var sortedArrays = [[Color]]()
        
        for index in 0..<toSort.count {
            var colors = toSort[index]
            sort(colors: &colors, sortIndex: index, pattern: pattern, sorter: sorter)
            sortedArrays.append(colors)
            if let p = progress {
                p(Float(index)/Float(toSort.count))
            }
        }
        let image = pattern.image(with: sortedArrays, size: image.size)
        return image
    }
    
    
    static fileprivate func sort(colors: inout [Color], sortIndex:  Int, pattern: SortPattern, sorter: PixelSorter) {
        if colors.count == 0 {
            return
        }
        
        //to create pattern, divide array into pieces and sort them separately
        let unsortedPhases = sortPhases(withColors: colors, sortIndex: sortIndex, pattern: pattern)
        
        var sortedPhases = [[Color]]()
        for var phase in unsortedPhases {
            quicksort(WithColors: &phase, low: 0, high: phase.count - 1, pixelsort: sorter)
            sortedPhases.append(phase)
        }
        colors = combinedColors(withSortPhases: sortedPhases)
    }
    
    /**
     @return phases to sort defined by input sort pattern
     */
    static fileprivate func sortPhases(withColors colors: [Color], sortIndex: Int, pattern: SortPattern) -> [[Color]]{
        
        if colors.count < 2 {
            return [colors]
        }
        
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

    
    static fileprivate func quicksort(WithColors colors : inout [Color], low: Int, high: Int, pixelsort: PixelSorter ){
        
        if colors.count == 0 {
            return
        }
        
        if low >= high {
            return
        }
        
        let middle = Int(Float(low) + Float(high - low) * 0.5)
        let index_factor = Float(low)/Float(colors.count)
        let pivot = pixelsort.order(by: colors[middle], index: index_factor, totalColors: colors.count)
        
        var i = low, j = high;
        while i <= j {
            while pixelsort.order(by: colors[i], index: index_factor, totalColors: colors.count) < pivot{
                i = i + 1
            }
            while pixelsort.order(by: colors[j], index: index_factor, totalColors: colors.count) > pivot{
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
            quicksort(WithColors: &colors, low: low, high: j, pixelsort: pixelsort)
        }
        
        if (high > i) {
            quicksort(WithColors: &colors, low: i, high: high, pixelsort: pixelsort)
        }
        
    }
}
