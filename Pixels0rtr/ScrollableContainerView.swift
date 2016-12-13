//
//  UIScrollableContainerView.swift
//  Pixels0rtr
//
//  Created by Norsez Orankijanan on 12/13/2559 BE.
//  Copyright © 2559 Bluedot. All rights reserved.
//

import UIKit

class ScrollableContainerView: UIScrollView {
    override func touchesShouldBegin(_ touches: Set<UITouch>, with event: UIEvent?, in view: UIView) -> Bool {
        return true
    }

}
