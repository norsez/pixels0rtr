//
//  PixelSorting.swift
//  Pixels0rtr
//
//  Created by Norsez Orankijanan on 11/30/2559 BE.
//  Copyright © 2559 Bluedot. All rights reserved.
//

import UIKit
import C4

//MARK: CMYK color model
class CMYK {
    var magenta, black, cyan, yellow: Float
    
    init(withARGB argb: [UInt8]) {
        //convert to CMY
        cyan = 1 - (Float(argb[1]) / 255)
        magenta = 1 - (Float(argb[2]) / 255)
        yellow = 1 - (Float(argb[3]) / 255)
        //convert to CMYK
        black = 1;
        if cyan < black {
            black = cyan
        }
        if (magenta < black) { black = magenta }
        if (yellow < black) { black = yellow }
        cyan = ( cyan - black ) / ( 1 - black );
        magenta = ( magenta - black ) / ( 1 - black );
        yellow = ( yellow - black ) / ( 1 - black );
        //convert to value between 0 and 100
        cyan = cyan * 100;
        magenta = magenta * 100;
        yellow = yellow * 100;
        black = black * 100;
    }
}

//MARK: optimized color stub for HSB access
class SortColor {
    
    fileprivate static var colorCache = [Int:SortColor]()
    
    let bytesARBG :[UInt8]
    var bytesAHSB :[UInt8] = [0,0,0,0]
    lazy var CMYKValues: CMYK = {
        let result = CMYK(withARGB: self.bytesARBG)
        return result
    }()
    
    var red: UInt8 {
        get {
            return self.bytesARBG[1]
        }
    }
    
    var green: UInt8 {
        get {
            return self.bytesARBG[2]
        }
    }
    
    var blue: UInt8 {
        get {
            return self.bytesARBG[3]
        }
    }
    
    var alpha: UInt8 {
        get {
            return self.bytesARBG[0]
        }
    }
    
    var hue: UInt8 {
        get {
            return self.bytesAHSB[1]
        }
    }
    var saturation: UInt8 {
        get {
            return self.bytesAHSB[2]
        }
    }
    
    var brightness: UInt8 {
        get {
            return self.bytesAHSB[3]
        }
    }
    
    static func clearCache() {
        self.colorCache.removeAll()
    }
    
    static func intializeColorTable(withCompletion completion: ()->Void) {
        for _a in 255..<256 {
            for _r in 0..<256 {
                for _b in 0..<256 {
                    for _g in 0..<256 {
                        let _ = SortColor(withRed: UInt8(_r), green: UInt8(_g), blue: UInt8(_b), alpha: UInt8(_a))
                    }
                }
            }
        }
    }
    
    init(withRed red:UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
        
        bytesARBG = [alpha, red, green, blue]
        let key = SortColor.integer(withBytes: bytesARBG)!
        if let cached = SortColor.colorCache[key] {
            self.bytesAHSB = cached.bytesAHSB
        }else{
            
            let c = UIColor(red: CGFloat(Float(red)/255.0),
                            green: CGFloat(Float(green)/255.0),
                            blue: CGFloat(Float(blue)/255.0),
                            alpha: CGFloat(Float(alpha)/255.0))
            
            var h:CGFloat = 0
            var s:CGFloat = 0
            var b:CGFloat = 0
            var a:CGFloat = 0
            c.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
            self.bytesAHSB = [UInt8(a * 255.0), UInt8(h * 255.0),UInt8(s * 255.0),UInt8(b * 255.0)]
            
            SortColor.colorCache[key] = self
        }
    }

    var C4Color: Color {
        get {
            return Color(red: Double(self.bytesARBG[1])/255.0,
                         green: Double(self.bytesARBG[2])/255.0,
                         blue: Double(self.bytesARBG[3])/255.0,
                         alpha: Double(self.bytesARBG[0])/255.0)
        }
    }
    
    var C4Pixel: Pixel {
        get {
            return Pixel(Int(self.red), Int(self.green), Int(self.blue), Int(self.alpha))
        }
    }
    
    fileprivate static func integer(withBytes bytes: [UInt8]) -> Int? {
        if bytes.count == 4 {
            let bigEndianValue = bytes.withUnsafeBufferPointer {
                ($0.baseAddress!.withMemoryRebound(to: UInt32.self, capacity: 1) { $0 })
                }.pointee
            let value = Int(UInt32(bigEndian: bigEndianValue))
            return value
        }
        return nil
    }
    
    var isTransparent: Bool {
        get {
            return self.alpha == 255
        }
    }
}

//MARK:
struct SortParam {
    var roughnessAmount: Double = 0
    var sortAmount: Double = 0.5
    var sorter: PixelSorter
    var pattern: SortPattern
    var motionAmount: Double = 0
    var orientation = SortOrientation.horizontal
    var maxPixels: AppConfig.MaxSize = .px600
    var sortRect: CGRect? = nil
    
    init(roughness: Double, sortAmount: Double, sorter: PixelSorter, pattern: SortPattern, maxPixels: AppConfig.MaxSize) {
        self.roughnessAmount = roughness
        self.sortAmount = sortAmount
        self.sorter = sorter
        self.pattern = pattern
        self.maxPixels = maxPixels
    }
}


//MARK:
protocol PixelSorter {
    var name: String {get}
    func order(by color: SortColor, index: Double, totalColors: Int, sortParam: SortParam)->Double
}

//MARK:
class PixelSorterFactory {
    
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
        
        return Double(color.brightness)
    }
}

//MARK: hue sorter
class SorterMagenta: PixelSorter {
    var name: String {
        get {
            return "Magenta"
        }
    }
    
    func order(by color: SortColor, index: Double, totalColors: Int, sortParam: SortParam) -> Double {
        return Double(color.CMYKValues.magenta)
    }
}

class SorterCyan: PixelSorter {
    var name: String {
        get {
            return "Cyan"
        }
    }
    
    func order(by color: SortColor, index: Double, totalColors: Int, sortParam: SortParam) -> Double {
        return Double(color.CMYKValues.cyan)
    }
}

class SorterYellow: PixelSorter {
    var name: String {
        get {
            return "Yellow"
        }
    }
    
    func order(by color: SortColor, index: Double, totalColors: Int, sortParam: SortParam) -> Double {
        return Double(color.CMYKValues.yellow)
    }
}

class SorterBlack: PixelSorter {
    var name: String {
        get {
            return "Black"
        }
    }
    
    func order(by color: SortColor, index: Double, totalColors: Int, sortParam: SortParam) -> Double {
        return Double(color.CMYKValues.black)
    }
}


class SorterHue: PixelSorter {
    var name: String {
        get {
            return "Hue"
        }
    }
    
    func order(by color: SortColor, index: Double, totalColors: Int, sortParam: SortParam)->Double {
        return Double(color.hue)
    }
}

class SorterSaturation: PixelSorter {
    var name: String {
        get {
            return "Saturation"
        }
    }
    
    func order(by color: SortColor, index: Double, totalColors: Int, sortParam: SortParam)->Double {
        
        return Double(color.saturation)
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
        return Double(color.brightness) * 255.0
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
        
        return map(Double(color.brightness), min: 0, max: 255, toMin: thres * Double(totalColors), toMax: Double(totalColors))
    }
}


//#MARK: sort0
extension CGImage {
    func sorted(withParam sp: SortParam, scanLineIndex: Int) -> CGImage? {
        let size = CGSize(width: CGFloat(self.width), height: CGFloat(self.height))
        let colorArrays = sp.pattern.colorArrays(of: self,
                                                 size: size,
                                                 sortOrientation: sp.orientation,
                                                 progress: {f in})
        let image = PixelSorting.sortedScanLine(withColorArrays: colorArrays, scanLineIndex: scanLineIndex, sortParam: sp, progress: {f in})
        return image?.cgImage
    }
}


//MARK: PixelSorting Stats
struct PixelSortingStats {
    var elapsedTime: TimeInterval
    var numberOfPixels: Int
    
}
//MARK: quick sort
class PixelSorting: NSObject {
    
    static func sorted(image: UIImage, sortParam: SortParam, progress: (Float)->Void) -> (output:UIImage?, stats: PixelSortingStats){
        
        let startTime = Date()
        
        let NUM_SCAN_LINES = sortParam.orientation == .horizontal ? Int(image.size.height) : Int(image.size.width)
        let scanLineDrawer = ScanLineDrawer(withCGSize: image.size, orientation: sortParam.orientation)
        for scanLineIndex in 0..<NUM_SCAN_LINES {
            let scanImage = image.scanLine(atIndex: scanLineIndex, orientation: sortParam.orientation)
            if let sortedScanImage = scanImage?.sorted(withParam: sortParam, scanLineIndex: scanLineIndex) {
                scanLineDrawer.draw(strip: sortedScanImage, index: scanLineIndex)
            }
            progress(Float(scanLineIndex)/Float(NUM_SCAN_LINES))
        }
        let resultImage = scanLineDrawer.makeImage()
        assert(resultImage!.size.width == image.size.width)
        let elapsedTime = Date().timeIntervalSince(startTime)
        let numPixels = Int(image.size.width * image.size.height)
        let stats = PixelSortingStats(elapsedTime: elapsedTime, numberOfPixels: numPixels)
        
        return (output: resultImage, stats:stats)
    }
    
    static func sorted0(image: UIImage, sortParam: SortParam, progress: (Float)->Void) -> UIImage? {
        let pattern = sortParam.pattern
        guard let cgImage = image.cgImage else {
            Logger.log("can't create cgImage from input image")
            return nil
        }
        
        let toSort = pattern.colorArrays(of: cgImage, size: image.size, sortOrientation: sortParam.orientation, progress: progress)
        //Logger.log("\(toSort.count) pieces to sort from \(SortColor.colorCache.count) colors")
        
        let sortedResult = PixelSorting.sorted(withColorArrays: toSort, size: image.size, sortParam: sortParam, progress: progress)
        return sortedResult
    }
    
    static func sortedScanLine(withColorArrays colorArrays: [[SortColor]], scanLineIndex:Int, sortParam: SortParam, progress: (Float)->Void) -> UIImage? {
        
        var colors = colorArrays[0]
        sort(colors: &colors, scanLineIndex: scanLineIndex, sortParam: sortParam)
        if sortParam.orientation == .vertical {
            colors.reverse()
        }
        
        let size = sortParam.orientation == .horizontal ? CGSize(width: CGFloat(colors.count), height: 1) : CGSize(width: 1, height: CGFloat(colors.count))
        
        let image = sortParam.pattern.image(with: [colors], size: size , sortOrientation: sortParam.orientation, progress: progress )
        return image.uiimage
    }
    
    static func sorted(withColorArrays colorArrays: [[SortColor]], size: CGSize, sortParam: SortParam, progress: (Float)->Void) -> UIImage? {
        var sortedArrays = [[SortColor]]()
        
        for index in 0..<colorArrays.count {
            var colors = colorArrays[index]
            sort(colors: &colors, scanLineIndex: index, sortParam: sortParam)
            sortedArrays.append(colors)
            progress(Float(index)/Float(colorArrays.count))
            
        }
        
        //Logger.log("finished sorting size \(size)")
        let image = sortParam.pattern.image(with: sortedArrays, size: size, sortOrientation: sortParam.orientation, progress: progress )
        return image.uiimage
    }
    
    
    static fileprivate func sort(colors: inout [SortColor], scanLineIndex:  Int, sortParam: SortParam) {
        if colors.count == 0 {
            Logger.log("no colors to sort")
            return
        }
        
        //to create pattern, divide array into pieces and sort them separately
        let unsortedPhases = sortPhases(withColors: colors, scanLineIndex: scanLineIndex, sortParam: sortParam)
        
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
    static fileprivate func sortPhases(withColors colors: [SortColor], scanLineIndex: Int, sortParam: SortParam) -> [[SortColor]]{
        
        if colors.count < 2 {
            return [colors]
        }
        
        
        let pattern = sortParam.pattern
        
        var results = [[SortColor]]()
        var curCol = [SortColor]()
        for i in 0..<colors.count {
            if pattern.resetSubsortBlock(withIndex: i, scanLineIndex: sortIndex, sortParam: sortParam) {
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
