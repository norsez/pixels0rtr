//
//  SortLoupeView.swift
//  Pixels0rtr
//
//  Created by Norsez Orankijanan on 1/12/2560 BE.
//  Copyright © 2560 Bluedot. All rights reserved.
//

import UIKit

class SortLoupeView: UIView, XYPadDelegate, SortParamUIViewControllerDelegate {
    
    fileprivate var imageView: UIImageView!
    fileprivate var imageToPreview: UIImage?
    fileprivate var originSelector: XYPadModel!
    fileprivate let initOrigin = XYValue(x:0.4, y: 0.5)
    
    fileprivate var previewImageView: UIImageView!
    fileprivate let SIZE_PREVIEW = 64
    
    var lastSortParam: SortParam!
    
    let previewEngine = SortingPreview()
    
    fileprivate func initialize () {
        self.imageView = UIImageView()
        self.imageView.frame = self.bounds
        self.imageView.clipsToBounds = true
        
        self.addSubview(self.imageView)
        
        self.previewImageView = UIImageView(frame: CGRect(x:0, y:0, width: self.SIZE_PREVIEW, height: self.SIZE_PREVIEW))
        self.imageView.addSubview(self.previewImageView)
        
        self.originSelector = XYPadModel(withXYPadView: self.imageView, initialValue: initOrigin)
        self.originSelector.delegate = self
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
        self.originSelector.lastValue = initOrigin
        self.updateLoupe(withSortParam: sortParam)
    }
    
    fileprivate func updateLoupe(withSortParam sp: SortParam) {
        self.lastSortParam = sp
        var f = self.previewImageView.frame
        f.origin = originSelector.lastValue
        self.previewImageView.frame = f
        
        if let imageToPreview = self.imageView.image {
            let previewParam = PreviewParam(image: imageToPreview, sortParam: self.lastSortParam, originX: Double(self.initOrigin.x), originY: Double(self.initOrigin.y), previewSize: self.SIZE_PREVIEW)
            
            self.previewEngine.createPreview(withParam: previewParam, progress: { (p) in
                //TODO: update progress ??
            }) { (previewImage) in
                if let pi = previewImage {
                    self.previewImageView.image = pi
                }
            }
        }
    }
    
    
    func xyPad(_ view: UIView, didTapValue: XYValue) {
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
