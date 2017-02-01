//
//  ThesholdControlModel.swift
//  Pixels0rtr
//
//  Created by Norsez Orankijanan on 1/31/2560 BE.
//  Copyright © 2560 Bluedot. All rights reserved.
//

import UIKit
import QuartzCore

fileprivate class GreenStripView: UIView {
    
    let gradient = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    func initialize() {
        let b = UIColor.black.cgColor
        let g = UIColor.green.cgColor
        gradient.colors = [b,g,g,b]
        gradient.locations = [0,0.2,0.8,1]
        gradient.startPoint = CGPoint(x:0,y:0.5)
        gradient.endPoint = CGPoint(x:1,y:0.5)
        self.layer.addSublayer(gradient)
    }
    
    fileprivate override func layoutSubviews() {
        super.layoutSubviews()
        self.gradient.frame = self.bounds
    }
    
}

class ThresholdControlView: UIView {
    
    let model = ThesholdModelController()
    var lowerView: UIView!
    var upperView: UIView!
    var greenView: UIView!
    fileprivate let WIDTH_LEVER: CGFloat = 26
    
    fileprivate var startX:CGFloat = 0
    fileprivate var startLever: UIView?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
        self.startLever = self.lowerView
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }
    
    func setDelegate(delegate: ThresholdModelControllerDelegate) {
        self.model.delegate = delegate
    }
    
    fileprivate func initialize() {
        self.backgroundColor = UIColor(white: 0, alpha: 0.2)
        self.layer.cornerRadius = 5
        
        self.greenView = GreenStripView(frame: self.bounds)
        self.greenView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
        self.addSubview(self.greenView)
        self.greenView.alpha = 0.2
        
        self.lowerView = UIView(frame: CGRect(x:0, y: 0, width: WIDTH_LEVER, height: self.bounds.height))
        self.lowerView.layer.backgroundColor = UIColor(white: 0, alpha: 0.75).cgColor
        self.lowerView.layer.borderWidth = 1
        self.lowerView.layer.borderColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0.25).cgColor
        self.lowerView.layer.cornerRadius = 5
        self.lowerView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
        self.addSubview(self.lowerView)
        self.upperView = UIView(frame: CGRect(x:self.bounds.width - WIDTH_LEVER, y: 0, width: WIDTH_LEVER, height: self.bounds.height))
        self.upperView.layer.backgroundColor = UIColor(white: 1, alpha: 0.25).cgColor
        self.upperView.layer.cornerRadius = self.lowerView.layer.cornerRadius
        self.upperView.layer.borderWidth = self.lowerView.layer.borderWidth
        self.upperView.layer.borderColor = self.lowerView.layer.borderColor
        self.upperView.autoresizingMask = self.lowerView.autoresizingMask
        self.addSubview(self.upperView)
        
        let pan1 = UIPanGestureRecognizer(target: self, action: #selector(panLever(pan:)))
        pan1.maximumNumberOfTouches = 1
        let pan2 = UIPanGestureRecognizer(target: self, action: #selector(panLever(pan:)))
        pan2.maximumNumberOfTouches = 1
        self.lowerView.addGestureRecognizer(pan1)
        self.upperView.addGestureRecognizer(pan2)
    }
    
    
    func panLever(pan: UIPanGestureRecognizer) {
        //must be moved by one of the levers
        guard let view = pan.view else {
            return
        }
        
        
        if pan.state == .changed {
            
            let loc = pan.location(in: self)
            let half_width = (WIDTH_LEVER * 0.5)
            
            var updateView = false
            
            if loc.x - half_width > 0
                && loc.x + half_width < bounds.size.width
            {
                let newCenter = CGPoint(x:loc.x, y: bounds.size.height * 0.5)
                
                if self.lowerView == view && newCenter.x + WIDTH_LEVER < self.upperView.center.x {
                    updateView = true
                    model.lowerValue = max(0,Double(newCenter.x / (bounds.size.width - WIDTH_LEVER)))
                }else if self.upperView == view && newCenter.x > self.lowerView.frame.maxX + (WIDTH_LEVER * 0.5) {
                    updateView = true
                    model.upperValue = min(1, Double(newCenter.x / (bounds.size.width - WIDTH_LEVER)))
                }
                
                Logger.log("\(model.lowerValue) - \(model.upperValue)")
                if updateView {
                    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.2, options: [.beginFromCurrentState], animations: {
                        view.center = newCenter
                        self.greenView.frame = CGRect(x: self.lowerView.frame.maxX, y: 0, width: self.upperView.frame.minX - self.lowerView.frame.maxX, height: self.bounds.size.height)
                    }, completion: nil)
                    
                }
            }
            
            
            
        }
    }
    
    fileprivate func moveLowerLeverToValue(value: Double) {
        var f = self.lowerView.frame
        f.origin = CGPoint(x:CGFloat(value) * (self.bounds.size.width - (WIDTH_LEVER * 2)), y:0)
        self.lowerView.frame = f
    }
    
    fileprivate func moveUpperLeverToValue(value: Double) {
        var f = self.upperView.frame
        f.origin = CGPoint(x:WIDTH_LEVER + (CGFloat(value) * (self.bounds.size.width - WIDTH_LEVER)), y:0)
        self.upperView.frame = f
    }
    
    func setLowerValue(value: Double) {
        if value > self.model.upperValue {
            fatalError("can't set lower > upper")
        }
        self.model.lowerValue = value
        self.moveLowerLeverToValue(value: value)
    }
    
    func setUpperValue(value: Double) {
        if self.model.upperValue < value {
            fatalError("can't set lower > upper")
        }
        self.model.upperValue = value
        self.moveUpperLeverToValue(value: value)
    }
}

protocol ThresholdModelControllerDelegate {
    func valuesDidChange(lower: Double, upper: Double)
}

class ThesholdModelController: NSObject {
    
    private var _lowerValue: Double = 0
    private var _upperValue: Double = 1
    
    var delegate: ThresholdModelControllerDelegate?
    
    var lowerValue: Double {
        get {
            return _lowerValue
        }
        
        set (v) {
            self._lowerValue = v
            self.delegate?.valuesDidChange(lower: _lowerValue, upper: _upperValue)
        }
    }
    
    var upperValue: Double {
        get {
            return _upperValue
        }
        
        set (v) {
            self._upperValue = v
            self.delegate?.valuesDidChange(lower: _lowerValue, upper: _upperValue)
        }
    }
    
}
