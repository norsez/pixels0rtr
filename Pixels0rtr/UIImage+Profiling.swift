//
//  UIImage+Profiling.swift
//  Pixels0rtr
//
//  Created by norsez on 12/8/16.
//  Copyright © 2016 Bluedot. All rights reserved.
//

import UIKit

extension UIImage {
    func canRender(atMaxSize maxSize: AppConfig.MaxSize) -> Bool {
        if self.size == CGSize.zero {
            return false
        }
        
        let imageMaxSize = self.maxSideSize
        return maxSize.pixels <= imageMaxSize
    }
    
    var maxSideSize: Int {
        get {
            return Int(max(self.size.width, self.size.height))
        }
    }
}
