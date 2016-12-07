//
//  PixelSorting.swift
//  Pixels0rtr
//
//  Created by Norsez Orankijanan on 11/30/2559 BE.
//  Copyright © 2559 Bluedot. All rights reserved.
//

import UIKit
import C4

//MARK: optimized color stub for HSB access
class SortColor {
    
    fileprivate static var colorCache = [String:SortColor]()
    
    var hue: Double = 0
    var brightness: Double = 0
    var saturation: Double = 0
    var red: Double = 0
    var green: Double = 0
    var blue: Double = 0
    var alpha: Double = 0
    init(withRed red:UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
        
        let key = "\(red)-\(green)-\(blue)-\(alpha)"
        if let cached = SortColor.colorCache[key] {
            self.hue = cached.hue
            self.brightness = cached.brightness
            self.saturation = cached.saturation
            self.alpha = cached.alpha
            self.red = cached.red
            self.green = cached.green
            self.blue = cached.blue
        }else{
            
            self.red = Double(red)/255.0
            self.green = Double(green)/255.0
            self.blue = Double(blue)/255.0
            self.alpha = Double(alpha)/255.0
            
            let c = UIColor(red: CGFloat(self.red),
                            green: CGFloat(self.green),
                            blue: CGFloat(self.blue),
                            alpha: CGFloat(self.alpha))
            
            var h:CGFloat = 0
            var s:CGFloat = 0
            var b:CGFloat = 0
            var a:CGFloat = 0
            c.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
            self.hue = Double(h)
            self.brightness = Double(b)
            self.saturation = Double(s)
            self.alpha = Double(a)
        }
    }

    var C4Color: Color {
        get {
            return Color(red: red, green: green, blue: blue, alpha: alpha)
        }
    }
}

//MARK:
struct SortParam {
    var motionAmount: Double = 0
    var sortAmount: Double = 0.5
    var sorter: PixelSorter
    var pattern: SortPattern
}


//MARK:
protocol PixelSorter {
    var name: String {get}
    func order(by color: SortColor, index: Double, totalColors: Int, sortParam: SortParam)->Double
}

//MARK:
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

//MARK: brightness sorter
class SorterBrightness: PixelSorter {
    var name: String {
        get {
            return "Brightness"
        }
    }
    
    func order(by color: SortColor, index: Double, totalColors: Int, sortParam: SortParam)->Double {
        
        return color.brightness
    }
}

//MARK: hue sorter
class SorterHue: PixelSorter {
    var name: String {
        get {
            return "Hue"
        }
    }
    
    func order(by color: SortColor, index: Double, totalColors: Int, sortParam: SortParam)->Double {
        return color.hue
    }
}

class SorterSaturation: PixelSorter {
    var name: String {
        get {
            return "Saturation"
        }
    }
    
    func order(by color: SortColor, index: Double, totalColors: Int, sortParam: SortParam)->Double {
        
        return color.saturation
    }
}

class SorterCenterSorted: PixelSorter {
    var name: String {
        get {
            return "Center Sorted"
        }
    }
    
    func order(by color: SortColor, index: Double, totalColors: Int, sortParam: SortParam)->Double {
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
    
    func order(by color: SortColor, index: Double, totalColors: Int, sortParam: SortParam)->Double {
        let thres = 0.4
        if index <= thres {
            return index * Double(totalColors)
        }
        
        return map(color.brightness, min: 0, max: 1, toMin: thres * Double(totalColors), toMax: Double(totalColors))
    }
}
//MARK: quick sort
class PixelSorting: NSObject {
    
    static func sorted(image: UIImage, sortParam: SortParam, progress: ((Float)->Void)?) -> UIImage? {
        let pattern = sortParam.pattern
        guard let cgImage = image.cgImage else {
            Logger.log("can't create cgImage from input image")
            return nil
        }
        
        let toSort = pattern.colorArrays(of: cgImage, size: image.size, progress: progress)
        Logger.log("\(toSort.count) pieces to sort")
        
        return PixelSorting.sorted(withColorArrays: toSort, size: image.size, sortParam: sortParam, progress: progress)
    }
    
    static func sorted(withColorArrays colorArrays: [[SortColor]], size: CGSize, sortParam: SortParam, progress: ((Float)->Void)?) -> UIImage? {
        var sortedArrays = [[SortColor]]()
        
        for index in 0..<colorArrays.count {
            var colors = colorArrays[index]
            sort(colors: &colors, sortIndex: index, sortParam: sortParam)
            sortedArrays.append(colors)
            if let p = progress {
                p(Float(index)/Float(colorArrays.count))
            }
        }
        
        Logger.log("finished sorting size \(size)")
        let image = sortParam.pattern.image(with: sortedArrays, size: size)
        return image.uiimage
    }
    
    
    static fileprivate func sort(colors: inout [SortColor], sortIndex:  Int, sortParam: SortParam) {
        if colors.count == 0 {
            Logger.log("no colors to sort")
            return
        }
        
        //to create pattern, divide array into pieces and sort them separately
        let unsortedPhases = sortPhases(withColors: colors, sortIndex: sortIndex, sortParam: sortParam)
        
        var sortedPhases = [[SortColor]]()
        for var phase in unsortedPhases {
            quicksort(WithColors: &phase, low: 0, high: phase.count - 1, sortParam: sortParam)
            sortedPhases.append(phase)
        }
        colors = combinedColors(withSortPhases: sortedPhases)
    }
    
    /**
     @return phases to sort defined by input sort pattern
     */
    static fileprivate func sortPhases(withColors colors: [SortColor], sortIndex: Int, sortParam: SortParam) -> [[SortColor]]{
        
        if colors.count < 2 {
            return [colors]
        }
        
        let pattern = sortParam.pattern
        
        var results = [[SortColor]]()
        var curCol = [SortColor]()
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
    static fileprivate func combinedColors(withSortPhases phases: [[SortColor]]) -> [SortColor] {
        //Logger.log("combining \(phases.count) sort phases")
        return phases.reduce([], { (npr, phase) -> [SortColor] in
            var result = npr
            result.append(contentsOf: phase)
            return result
        })
    }

    
    static fileprivate func quicksort(WithColors colors : inout [SortColor], low: Int, high: Int, sortParam: SortParam){
        
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
