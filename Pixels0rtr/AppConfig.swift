//
//  AppConfig.swift
//  Pixels0rtr
//
//  Created by Norsez Orankijanan on 12/1/2559 BE.
//  Copyright © 2559 Bluedot. All rights reserved.
//

import UIKit

class AppConfig: NSObject {
    
    enum MaxSize: String {
        case px600, px1200, px2400, pxTrueSize
        var pixels: Int {
            get {
                switch self {
                case .px600:
                    return 600
                case .px1200:
                    return 1200
                case .px2400:
                    return 2400
                case .pxTrueSize:
                    return 0
                }
            }
        }
        
      static let ALL_SIZES: [MaxSize] = [.px600, .px1200, .px2400, .pxTrueSize]
        
    }
    
    enum Config: String {
        case Sorter, Pattern, SortAmount, MotionAmount, MaxSize
    }
    
    
    var SortParameters: SortParam {
        get {
            
            let uf = UserDefaults.standard
            
            let pixelSorter = PixelSorterFactory.sorter(with: uf.string(forKey: Config.Sorter.rawValue) ?? "")!
            let sortPattern = PatternClassic()
            
            let sp = SortParam(motionAmount: uf.double(forKey: Config.MotionAmount.rawValue),
                               sortAmount: uf.double(forKey: Config.SortAmount.rawValue),
                            sorter: pixelSorter,
                            pattern: sortPattern)
            return sp
        }
    }
    
    
    //#MARK: - singleton
    static let shared: AppConfig = {
        let instance = AppConfig()
        
        let uf = UserDefaults.standard
        let defaults: [String:Any] = [
            Config.Sorter.rawValue: "Brightness",
            Config.Pattern.rawValue: "Classic",
            Config.SortAmount.rawValue: 0.5,
            Config.MotionAmount.rawValue: 0.5,
            Config.MaxSize.rawValue: MaxSize.px600.pixels
        ]
        uf.register(defaults: defaults)
        
        return instance
    }()

}
