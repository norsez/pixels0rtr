//
//  SortLoupeView.swift
//  Pixels0rtr
//
//  Created by Norsez Orankijanan on 1/12/2560 BE.
//  Copyright © 2560 Bluedot. All rights reserved.
//

import UIKit
import QuartzCore

protocol SortLoupeViewDelegate {
    func loupeDidMove(toLocation: XYValue)
}

class SortLoupeView: UIView, XYPadDelegate {
    
    fileprivate var imageView: UIImageView!
    fileprivate var imageToPreview: UIImage?
    fileprivate var originSelector: XYPadModel!
    fileprivate let initOrigin = XYValue(x:0.4, y: 0.5)
    
    fileprivate var previewImageView: UIImageView!
    fileprivate var progressView: UIProgressView!
    
    var imageInLoupe: UIImage?
    
    var lastSortParam: SortParam!
    var currentOrigin = XYValue(x:0.4, y: 0.5)
    let previewEngine = SortingPreview()
    
    var busyUpdating = false
    var loupeSize : CGSize = CGSize(width: 80, height: 80)
    
    var delegate: SortLoupeViewDelegate?
    
    fileprivate func initialize () {
        self.backgroundColor = UIColor.clear
        
        self.imageView = UIImageView()
        self.imageView.frame = self.bounds
        self.imageView.clipsToBounds = true
        self.imageView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(self.imageView)
        
        self.previewImageView = UIImageView(frame: CGRect(x:0, y:0, width: 0, height: 0))
        self.previewImageView.layer.borderWidth = 1
        self.previewImageView.layer.borderColor = APP_COLOR_FONT.cgColor
        self.previewImageView.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin]
        self.imageView.addSubview(self.previewImageView)
        self.previewImageView.alpha = 0
        self.previewImageView.layer.cornerRadius = 5
        
        let crosshair = UILabel(frame: CGRect(x:-10,y:-10, width:20, height: 20))
        crosshair.font = APP_FONT?.withSize(36)
        crosshair.text = "+"
        crosshair.textAlignment = .center
        crosshair.textColor = APP_COLOR_FONT.withAlphaComponent(0.8)
        self.previewImageView.addSubview(crosshair)
        
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
    
    func showImage(image: UIImage, loupeRect: CGRect) {
        self.imageView.image = image
        self.previewImageView.image = nil
        self.previewImageView.alpha = 1
        var newLoupeFrame = CGRect.zero
        let factor = self.imageView.bounds.size.width / image.size.width
        newLoupeFrame.origin = CGPoint(x: loupeRect.origin.x * factor, y: loupeRect.origin.y * factor)
        newLoupeFrame.size = CGSize(width: loupeRect.size.width * factor, height: loupeRect.size.height * factor)
        self.previewImageView.frame = newLoupeFrame
    }
    
    func showImage(image: UIImage?) {
        UIView.animate(withDuration: 0.5, delay: 0, options: [], animations: {
            self.previewImageView.alpha = 0
        }, completion: { (f) in
            if f {
                self.animateChangeImage(image: image, imageView: self.imageView, location: nil) {
                        self.imageInLoupe = nil
                }
                
            }
        })
        
    }
    
    func moveLoupeToLocation(location: XYValue) {
        guard let li = self.imageInLoupe else {
            return
        }
        
        let loupeImageOrigin = CGPoint(x: CGFloat(location.x * li.size.width),
                                       y: CGFloat(location.y * li.size.height))
        var frame = CGRect.zero
        frame.size = self.loupeSize
        frame.origin = loupeImageOrigin
        if let cgCroppedImage = li.cgImage?.cropping(to: frame){
            let croppedImage = UIImage(cgImage: cgCroppedImage)
            self.animateChangeImage(image: croppedImage, imageView: self.previewImageView, location: location) {
                self.currentOrigin = location
            }
        }
        
    }
    
    func showImage(image: UIImage, inLoupeWithImage limage: UIImage) {
        self.imageInLoupe = limage
        self.animateChangeImage(image: image, imageView: self.imageView, location: nil) {
            self.moveLoupeToLocation(location: self.currentOrigin)
        }
    }
    
    fileprivate func animateChangeImage(image: UIImage?, imageView: UIImageView, location: XYValue? = nil, completion: (()->Void)? = nil) {
        
        let DURATION = 0.5
        
        var newFrame: CGRect?
        if let loc = location {
            newFrame = CGRect(x: loc.x * self.bounds.width ,
                               y: loc.y * self.bounds.height,
                               width: self.loupeSize.width,
                               height: self.loupeSize.height)
        }
        
        UIView.animate(withDuration: DURATION,
                       animations: { 
                        imageView.alpha = 0
        }) { (f) in
            if f {
                imageView.image = image
                UIView.animate(withDuration: DURATION,
                               animations: { 
                                imageView.alpha = 1
                                if let f = newFrame {
                                    imageView.frame = f
                                }
                }, completion: { (f) in
                    if let c = completion {
                        c()
                    }
                })
            }
        }
        
    }
    
    //MARK :
    func xyPad(_ view: UIView, didTapValue loc: XYValue) {
        self.currentOrigin = loc
//        self.updateLoupe(withSortParam: self.lastSortParam)
        self.moveLoupeToLocation(location: loc)
        
        if let dl = self.delegate {
            dl.loupeDidMove(toLocation: loc)
        }
    }
    
    func xyPad(_ view: UIView, changePanValue location: XYValue) {
        if let li = self.imageInLoupe {
            let loupeImageOrigin = CGPoint(x: CGFloat(location.x * li.size.width),
                                           y: CGFloat(location.y * li.size.height))
            var frame = CGRect(x: 0, y: 0, width: self.loupeSize.width, height: self.loupeSize.height)
            frame.origin = loupeImageOrigin
            self.previewImageView.frame = frame
        }
        
        if let dl = self.delegate {
            dl.loupeDidMove(toLocation: location)
        }
    }
        
    func xyPad(_ view: UIView, didPanValue loc: XYValue) {
        self.moveLoupeToLocation(location: loc)
        if let dl = self.delegate {
            dl.loupeDidMove(toLocation: loc)
        }
    }
    
    
    
}
