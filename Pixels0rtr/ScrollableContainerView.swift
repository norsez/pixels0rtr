//
//  UIScrollableContainerView.swift
//  Pixels0rtr
//
//  Created by Norsez Orankijanan on 12/13/2559 BE.
//  Copyright © 2559 Bluedot. All rights reserved.
//

import UIKit

class ScrollableContainerView: UIScrollView {
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let result = super.hitTest(point, with: event)
        return result
    }
}
