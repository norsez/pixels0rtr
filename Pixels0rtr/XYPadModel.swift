//
//  XYPadDelegate.swift
//  Pixels0rtr
//
//  Created by Norsez Orankijanan on 12/23/2559 BE.
//  Copyright © 2559 Bluedot. All rights reserved.
//

import UIKit

//MARK: XYValue
typealias XYValue = CGPoint

extension CGPoint {
    func normalizedDelta(toPoint p2:CGPoint, boundSize: CGSize) -> XYValue {
        let dX = Double(p2.x - self.x)/Double(boundSize.width)
        let dY = Double(p2.y - self.y)/Double(boundSize.height)
        return XYValue(x:CGFloat(dX), y: CGFloat(dY))
    }
}

extension XYValue {
    func add(_ value:XYValue) -> XYValue {
        let x = min(max(self.x + value.x, 0), 1)
        let y = min(max(self.y + value.y, 0), 1)
        return XYValue(x: x, y: y)
    }
    
    func asPoint(inBoundSize size:CGSize) -> CGPoint {
        let x = CGFloat(self.x * size.width)
        let y = CGFloat(self.y * size.height)
        return CGPoint(x: x, y: y)
    }
}

//MARK: delegate
protocol XYPadDelegate {
    func xyPad(_ view:UIView, didTapValue: XYValue)
    func xyPad(_ view:UIView, changePanValue: XYValue)
    func xyPad(_ view:UIView, didPanValue: XYValue)
    
}
//MARK: model code
class XYPadModel {
    var delegate: XYPadDelegate?
    var lastValue: XYValue = CGPoint.zero
    
    fileprivate var xyPadView: UIView
    fileprivate let appWindow: UIWindow
    
    fileprivate var panOrigin: XYValue = XYValue.zero
    
    init(withXYPadView xyPad: UIView, initialValue: XYValue) {
        let app = UIApplication.shared.delegate as! AppDelegate
        self.appWindow = app.window!
        self.xyPadView = xyPad
        self.lastValue = initialValue
        let xyTap = UITapGestureRecognizer(target: self, action: #selector(didTapXYPad(_:)))
        xyTap.numberOfTapsRequired = 1
        xyTap.numberOfTouchesRequired = 1
        let xyPan = UIPanGestureRecognizer(target: self, action: #selector(didPanXYPad(_:)))
        xyPan.maximumNumberOfTouches = 1
        xyPan.minimumNumberOfTouches = 1
        self.xyPadView.addGestureRecognizer(xyTap)
        self.xyPadView.addGestureRecognizer(xyPan)
        
    }
    
    @objc func didTapXYPad(_ gr: UITapGestureRecognizer) {
        
        let point = gr.location(in: self.xyPadView)
        if self.xyPadView.bounds.contains(point) == false {
            return
        }
        
        if gr.state == .ended {
            let point = gr.location(in: self.xyPadView)
            let x = Double(point.x)/Double(self.xyPadView.bounds.width)
            let y = Double(point.y)/Double(self.xyPadView.bounds.height)
            let p = CGPoint(x:CGFloat(x), y: CGFloat(y))
            
            self.delegate?.xyPad(self.xyPadView, didTapValue: p)
            
            self.lastValue = p
        }
    }
    
    @objc func didPanXYPad(_ gr: UIPanGestureRecognizer) {
        let point = gr.location(in: appWindow)
        
        if gr.state == .began {
            self.panOrigin = point
        }else if gr.state == .changed {
            let nDelta = self.panOrigin.normalizedDelta(toPoint: point, boundSize: self.appWindow.bounds.size)
            let value = self.lastValue.add(nDelta)
            self.delegate?.xyPad(self.xyPadView, changePanValue: value)
        }else if gr.state == .ended {
            let nDelta = self.panOrigin.normalizedDelta(toPoint: point, boundSize: self.appWindow.bounds.size)
            let value = self.lastValue.add(nDelta)
            self.delegate?.xyPad(self.xyPadView, didPanValue: value)
            self.lastValue = value
            
        }
    }
    
    
}
