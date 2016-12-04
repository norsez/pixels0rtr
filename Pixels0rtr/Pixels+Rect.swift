//
//  Pixels+Rect.swift
//  Pixels0rtr
//
//  Created by norsez on 12/3/16.
//  Copyright © 2016 Bluedot. All rights reserved.
//

import UIKit
import C4

extension Image {
    
    func colors(at rect: CGRect) -> [Color] {
        var colors = [Color]()
        //scan through by height
        for y in 0..<Int(rect.size.height) {
            for x in 0..<Int(rect.size.width) {
                let point = Point(CGPoint(x:CGFloat(x) + rect.origin.x, y: CGFloat(y) + rect.origin.y))
                let c = self.color(at: point)
                colors.append(c)
            }
        }
        return colors
    }
    
}
