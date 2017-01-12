//
//  SortLoupeView.swift
//  Pixels0rtr
//
//  Created by Norsez Orankijanan on 1/12/2560 BE.
//  Copyright © 2560 Bluedot. All rights reserved.
//

import UIKit
import QuartzCore


class SortLoupeView: UIView, XYPadDelegate, SortParamUIViewControllerDelegate {
    
    fileprivate var imageView: UIImageView!
    fileprivate var imageToPreview: UIImage?
    fileprivate var originSelector: XYPadModel!
    fileprivate let initOrigin = XYValue(x:0.4, y: 0.5)
    
    fileprivate var previewImageView: UIImageView!
    fileprivate let SIZE_PREVIEW:CGFloat = 200
    fileprivate let SIZE_LOUPE:CGFloat = 64
    fileprivate var progressView: UIProgressView!
    
    var lastSortParam: SortParam!
    var currentOrigin = XYValue(x:0.4, y: 0.5)
    let previewEngine = SortingPreview()
    
    var busyUpdating = false
    
    fileprivate func initialize () {
        self.backgroundColor = UIColor.clear
        
        self.imageView = UIImageView()
        self.imageView.frame = self.bounds
        self.imageView.clipsToBounds = true
        self.imageView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(self.imageView)
        
        self.previewImageView = UIImageView(frame: CGRect(x:0, y:0, width: self.SIZE_LOUPE, height: self.SIZE_LOUPE))
        self.previewImageView.layer.borderWidth = 1
        self.previewImageView.layer.borderColor = APP_COLOR_FONT.cgColor
        self.previewImageView.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin]
        self.imageView.addSubview(self.previewImageView)
        self.previewImageView.alpha = 0
        
        self.originSelector = XYPadModel(withXYPadView: self, initialValue: initOrigin)
        self.originSelector.delegate = self
        
        self.progressView = UIProgressView(progressViewStyle: .default)
        self.progressView.progressTintColor = APP_COLOR_FONT
        self.progressView.trackTintColor = UIColor.clear
        self.progressView.progress = 0
        self.progressView.frame = CGRect(x:0,y:0,width: self.previewImageView.bounds.width, height: 2)
        self.progressView.autoresizingMask = [.flexibleWidth]
        self.previewImageView.addSubview(self.progressView)
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    func setImageToPreview(_ image: UIImage, sortParam: SortParam) {
        self.imageToPreview = image
        self.imageView.image = image
        self.originSelector.lastValue = initOrigin
        self.updateLoupe(withSortParam: sortParam)
    }
    
    func updateLoupe(withSortParam sp: SortParam) {
        
        if busyUpdating {
            return
        }
        
        self.lastSortParam = sp
        
        if let imageToPreview = self.imageToPreview {
            self.imageView.image = imageToPreview
            let previewOrigin = self.currentOrigin
            self.animateChangePreviewImage(image: imageToPreview, location: previewOrigin)
            
            let previewParam = PreviewParam(image: imageToPreview, sortParam: self.lastSortParam, originX: Double(previewOrigin.x), originY: Double(previewOrigin.y), previewSize: Int(self.SIZE_PREVIEW))
            self.progressView.progress = 0.1
            self.previewEngine.createPreview(withParam: previewParam, progress: { (p) in
                    self.progressView.alpha = 1
                    self.progressView.progress = p
                
            }) { (previewImage) in
                
                self.progressView.progress = 0
                
                
                if let pi = previewImage {
                    self.animateChangePreviewImage(image: pi, location: previewOrigin)
                }
                
                self.busyUpdating = false
            }
        }
    }
    
    func showImage(image: UIImage) {
        self.imageView.image = image
        self.previewImageView.alpha = 0
    }
    
    fileprivate func animateChangePreviewImage(image: UIImage, location: XYValue?) {
        
        let DURATION = 0.5
        
        var newFrame: CGRect?
        if let loc = location {
            newFrame = CGRect(x: loc.x * self.bounds.width ,
                               y: loc.y * self.bounds.height,
                               width: self.SIZE_LOUPE,
                               height: self.SIZE_LOUPE)
        }
        
        UIView.animate(withDuration: DURATION,
                       animations: { 
                        self.previewImageView.alpha = 0
        }) { (f) in
            if f {
                self.previewImageView.image = image
                UIView.animate(withDuration: DURATION,
                               animations: { 
                                self.previewImageView.alpha = 1
                                if let f = newFrame {
                                    self.previewImageView.frame = f
                                }
                }, completion: { (f) in
                    //nothing to do
                })
            }
        }
        
    }
    
    
    func xyPad(_ view: UIView, didTapValue loc: XYValue) {
        self.currentOrigin = loc
        self.updateLoupe(withSortParam: self.lastSortParam)
    }
    
    func xyPad(_ view: UIView, changePanValue: XYValue) {
        //nothing
    }
        
    func xyPad(_ view: UIView, didPanValue: XYValue) {
        //nothing
    }
    
    func paramValueDidChange(toParam sp: SortParam) {
        self.updateLoupe(withSortParam: sp)
    }
    
}
