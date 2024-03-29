//
//  AppConfig.swift
//  Pixels0rtr
//
//  Created by Norsez Orankijanan on 12/1/2559 BE.
//  Copyright © 2559 Bluedot. All rights reserved.
//

import UIKit

let ALBUM_NAME = "Pixels0rtr"
let ALL_SORT_PATTERNS: [SortPattern] = [PatternClassic(), PatternClean(), PatternOffset(), PatternStripe()]
let ALL_SORTERS: [PixelSorter] = [SorterBrightness(), SorterHue(), SorterSaturation(), SorterCenterSorted(), SorterIntervals(), SorterMagenta(), SorterCyan(), SorterYellow(), SorterBlack()]
let APP_COLOR_FONT = UIColor(red: 0, green: 1, blue: 0, alpha: 0.85)
let APP_FONT = UIFont(name: "Silom", size: 12)

//MARK: AppConfig
class AppConfig: NSObject {
    
    struct Key {
        static let FreeVersion = "FreeVersion"
    }
    
    enum MaxSize: Int, CustomStringConvertible {
        case px600, px1200, px2400, px3600, pxTrueSize
        
        var pixels: Int {
            get {
                switch self {
                case .px600:
                    return 600
                case .px1200:
                    return 1200
                case .px2400:
                    return 2400
                case .px3600:
                    return 3600
                case .pxTrueSize:
                    return 0
                }
            }
        }
        var description: String {
            get {
                if self == .pxTrueSize {
                    return "True"
                }else {
                    return "\(self.pixels)p"
                }
            }
        }
        static func allsortedSizes(withCustomPixelSize pixels: Int) -> [MaxSize] {
            var all = ALL_SIZES
            for i in 0..<all.count {
                let s = ALL_SIZES[i]
                if s.pixels > pixels {
                    all.insert(.pxTrueSize, at: i)
                }
            }
            return all
        }
        
      static let ALL_SIZES: [MaxSize] = [.px600, .px1200, .px2400, .px3600]
        
        static func maxSize(fromPixels numPixels:Int) -> MaxSize? {
            for ms in ALL_SIZES {
                if ms.pixels == numPixels {
                    return ms
                }
            }
            return nil
        }
        
    }
    
    enum Config: String {
        case Sorter, Pattern, SortAmount, RoughnessAmount, MaxSize, SortOrientation, isNotFirstLaunch, MotionAmount, LabMode
    }
    
    enum LabMode: Int {
        case xyPad, randomized
    }
    
    var sortOrientation: SortOrientation {
        get {
            let savedValue = UserDefaults.standard.integer(forKey: Config.SortOrientation.rawValue)
            return SortOrientation(rawValue: savedValue) ?? .down
        }
        
        set (value) {
            UserDefaults.standard.setValue(value.rawValue, forKey: Config.SortOrientation.rawValue)
            UserDefaults.standard.synchronize()
        }
    }
    
    var _maxPixels: MaxSize {
        get {
            let savedValue = UserDefaults.standard.integer(forKey: Config.MaxSize.rawValue)
            return MaxSize.ALL_SIZES[savedValue]
        }
        
        set (value) {
            UserDefaults.standard.setValue(value.rawValue, forKey: Config.MaxSize.rawValue)
            UserDefaults.standard.synchronize()
        }
    }
    
    var sortAmount: Double {
        get {
            return UserDefaults.standard.double(forKey: Config.SortAmount.rawValue)
        }
        set (value) {
            UserDefaults.standard.setValue(value, forKey: Config.SortAmount.rawValue)
            UserDefaults.standard.synchronize()
        }
    }
    
    var roughnessAmount: Double {
        get {
            return UserDefaults.standard.double(forKey: Config.RoughnessAmount.rawValue)
        }
        set (value) {
            UserDefaults.standard.setValue(value, forKey: Config.RoughnessAmount.rawValue)
            UserDefaults.standard.synchronize()
        }
    }
    
    var SortParameters: SortParam {
        get {
            
            let uf = UserDefaults.standard
            
            let pixelSorter = PixelSorterFactory.sorter(with: uf.string(forKey: Config.Sorter.rawValue) ?? "")!
            let sortPattern = PatternClassic()
            
            let sp = SortParam(roughness: uf.double(forKey: Config.RoughnessAmount.rawValue),
                               sortAmount: uf.double(forKey: Config.SortAmount.rawValue),
                            sorter: pixelSorter,
                            pattern: sortPattern,
                            maxPixels: .px600
                            )
            return sp
        }
    }
    
    var isNotFirstLaunch: Bool {
        set (v) {
            UserDefaults.standard.setValue(v, forKey: Config.isNotFirstLaunch.rawValue)
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.bool(forKey: Config.isNotFirstLaunch.rawValue)
        }
    }
    
    var isFreeVersion: Bool {
        set(v) {
            UserDefaults.standard.setValue(v, forKey: AppConfig.Key.FreeVersion)
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.bool(forKey: AppConfig.Key.FreeVersion)
        }
    }
    var labMode: LabMode {
        set(v) {
            UserDefaults.standard.set(v.rawValue, forKey: Config.LabMode.rawValue)
            UserDefaults.standard.synchronize()
        }
        get {
            let v = UserDefaults.standard.integer(forKey: Config.LabMode.rawValue)
            return LabMode(rawValue: v) ?? .xyPad
        }
    }
    
    
    var lastSortParam: SortParam?
    var lastImage: UIImage?
    var lastImagePath: String?
    
    //#MARK: - singleton
    static let shared: AppConfig = {
        let instance = AppConfig()
        
        let uf = UserDefaults.standard
        let defaults: [String:Any] = [
            Config.Sorter.rawValue: "Brightness",
            Config.Pattern.rawValue: "Classic",
            Config.SortAmount.rawValue: 0.5,
            Config.RoughnessAmount.rawValue: 0.5,
            Config.MotionAmount.rawValue: 0,
            Config.MaxSize.rawValue: MaxSize.px600.rawValue,
            Config.SortOrientation.rawValue: SortOrientation.down.rawValue,
            Config.LabMode.rawValue: LabMode.xyPad.rawValue,
            AppConfig.Key.FreeVersion: true
        ]
        uf.register(defaults: defaults)
        
        return instance
    }()

}
