//
//  PixelSorting.swift
//  Pixels0rtr
//
//  Created by Norsez Orankijanan on 11/30/2559 BE.
//  Copyright © 2559 Bluedot. All rights reserved.
//

import UIKit

protocol PixelSorter {
    var name: String {get}
    func order(byColor color: UIColor, index: Float, totalColors: Int)->Float
}

class SorterBrightness: PixelSorter {
    var name: String {
        get {
            return "Brightness"
        }
    }
    
    func order(byColor color: UIColor, index: Float, totalColors: Int) -> Float {
        var b: CGFloat = 0;
        color.getHue(nil, saturation: nil, brightness: &b, alpha: nil)
        return Float(b);
        
    }
}

class PixelSorting: NSObject {
    
    func sortedImage(withImage image: UIImage, pattern: SortPattern, sorter: PixelSorter) -> UIImage {
        
        var sortedColumns = [[UIColor]]()
        for colIndex in 0..<Int(image.size.width) {
            var columnOfPixels = image.pixels(withColumnIndex: colIndex)!
            sort(colorsToSort: &columnOfPixels, forColumnIndex: colIndex, pattern: pattern, sorter: sorter)
            sortedColumns.append(columnOfPixels)
        }
        
        return UIImage.image(withPixelColumns: sortedColumns)
    }
    
    
    fileprivate func sort(colorsToSort: inout [UIColor], forColumnIndex colIndex: Int, pattern: SortPattern, sorter: PixelSorter) {
        if colorsToSort.count == 0 {
            return
        }
        
        //to create pattern, divide array into pieces and sort them separately
        let unsortedPhases = sortPhases(withColors: colorsToSort, forColumnIndex: colIndex, pattern: pattern)
        
        var sortedPhases = [[UIColor]]()
        for var phase in unsortedPhases {
            quicksort(WithColors: &phase, low: 0, high: phase.count, pixelsort: sorter)
            sortedPhases.append(phase)
        }
        colorsToSort = colors(withSortPhases: sortedPhases)
    }
    
    /**
     @return phases to sort defined by input sort pattern
     */
    fileprivate func sortPhases(withColors colors: [UIColor], forColumnIndex colIndex: Int, pattern: SortPattern) -> [[UIColor]]{
        
        if colors.count < 2 {
            return [colors]
        }
        
        var results = [[UIColor]]()
        var curCol = [UIColor]()
        for i in 0..<colors.count {
            if pattern.resetSubsortBlock(withRow: i, column: colIndex) {
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
    fileprivate func colors(withSortPhases phases: [[UIColor]]) -> [UIColor] {
        return phases.reduce([], { (npr, phase) -> [UIColor] in
            var result = npr
            result.append(contentsOf: phase)
            return result
        })
    }

    
    fileprivate func quicksort(WithColors colors : inout [UIColor], low: Int, high: Int, pixelsort: PixelSorter ){
        
        if colors.count == 0 {
            return
        }
        
        if low >= high {
            return
        }
        
        let middle = Int(Float(low) + Float(high - low) * 0.5)
        let index_factor = Float(low)/Float(colors.count)
        let pivot = pixelsort.order(byColor: colors[middle], index: index_factor, totalColors: colors.count)
        
        var i = low, j = high;
        while i <= j {
            while pixelsort.order(byColor: colors[i], index: index_factor, totalColors: colors.count) < pivot{
                i = i + 1
            }
            while pixelsort.order(byColor: colors[j], index: index_factor, totalColors: colors.count) > pivot{
                j = j + 1
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
    
    
    
    //    func partition(colors: inout [UIColor], left: Int, right: Int, pixelSort: PixelSorter) -> Int{
    //        var i = left, j = right
    //        let pivot = colors[Int(Float(left+right)*0.5)]
    //        let index = Float(i)/Float(colors.count)
    //        let NUM_COLORS = colors.count
    //        let order_i = pixelSort.order(byColor: colors[i], index: index, totalColors: NUM_COLORS)
    //        let order_j = pixelSort.order(byColor: colors[j], index: index, totalColors: NUM_COLORS)
    //        let pivot_vc = pixelSort.order(byColor: pivot, index: index, totalColors: NUM_COLORS)
    //
    //        while i <= j {
    //            let tmp = colors[i]
    //            colors[i] = colors[j]
    //            colors[j] = tmp
    //            i = i + 1
    //            j = j + 1
    //        }
    //        
    //    }
    
    
}
