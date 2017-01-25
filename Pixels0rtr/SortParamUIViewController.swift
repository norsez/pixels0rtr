//
//  SortParamUIViewController.swift
//  Pixels0rtr
//
//  Created by norsez on 12/13/16.
//  Copyright © 2016 Bluedot. All rights reserved.
//

import UIKit

protocol SortParamUIViewControllerDelegate {
    func paramValueDidChange(toParam: SortParam)
}

class SortParamUIViewController: UIViewController, XYPadDelegate {

    @IBOutlet weak var xyPadImageView: UIImageView!
    @IBOutlet weak var xyPadView: UIView!
    @IBOutlet var sizeSelector: UISegmentedControl!
    @IBOutlet var sortOrientationSelector: UISegmentedControl!
    @IBOutlet var patternContainerView: UIView!
    @IBOutlet var sorterContainerView: UIView!
    @IBOutlet var xyLabel: UILabel!
    
    @IBOutlet var blackThresholdView: UIView!
    @IBOutlet var blackThresholdLebel: UILabel!
    @IBOutlet var whiteThresholdView: UIView!
    @IBOutlet var whiteThresholdLabel: UILabel!
    
    @IBOutlet var constraintBottomXYPad: NSLayoutConstraint!
    @IBOutlet var constraintTopXYPad: NSLayoutConstraint!
    @IBOutlet var constraintWidthXYPad: NSLayoutConstraint!
    @IBOutlet var constraightHeightXYPad: NSLayoutConstraint!
    var delegates = [SortParamUIViewControllerDelegate]()
    
    var sorterSelector: HorizontalSelectorCollectionViewController!
    var patternSelector: HorizontalSelectorCollectionViewController!
    
    var currentSizeOrder: [AppConfig.MaxSize] = []
    
    var totalHeight: CGFloat {
        get {
            return self.sizeSelector.frame.maxY + 150
        }
    }
    var xyPadModel: XYPadModel!
    var blackThresholdPadModel: XYPadModel!
    var whiteThresholdPadModel: XYPadModel!
    var blackThresholdValue: UInt8 = 0
    var whiteThresholdValue: UInt8 = 255
    
    var roughness: Double = 0
    var sortAmount: Double = 0
    var sorter: PixelSorter = SorterBrightness()
    var pattern: SortPattern = PatternClassic()
    
    var currentParameters: SortParam {
        get{
            let maxPixels = self.currentSizeOrder[self.sizeSelector.selectedSegmentIndex]
            var sp = SortParam(roughness: self.roughness, sortAmount: self.sortAmount, sorter: self.sorter, pattern: self.pattern, maxPixels: maxPixels)
            sp.orientation = SortOrientation(rawValue: self.sortOrientationSelector.selectedSegmentIndex)!
            sp.whiteThreshold = self.whiteThresholdValue
            sp.blackThreshold = self.blackThresholdValue
            return sp
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var ctRect = self.sorterContainerView.bounds
        ctRect.origin = CGPoint.zero
        self.sizeSelector.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Silom", size: 12) as Any], for: .normal)
        
        self.sortOrientationSelector.selectedSegmentIndex = AppConfig.shared.sortOrientation.rawValue
        
        sorterSelector = self.storyboard?.instantiateViewController(withIdentifier: "horizontalSelector") as! HorizontalSelectorCollectionViewController
        sorterSelector.items = ALL_SORTERS.flatMap({ (ps) -> HorizontalSelectItem? in
            return HorizontalSelectItem(image: nil, title: ps.name)
        })
        self.addChildViewController(sorterSelector)
        self.sorterSelector.view.frame = ctRect
        self.sorterSelector.view.translatesAutoresizingMaskIntoConstraints = false
        self.sorterContainerView.addSubview(sorterSelector.view)
        self.sorterSelector.didMove(toParentViewController: self)
        self.sorterSelector.didSelectItem = { index in
            self.sorter = ALL_SORTERS[index]
            self.notifyChangeToDelegates()
        }
        
        
        
        patternSelector = self.storyboard?.instantiateViewController(withIdentifier: "horizontalSelector") as! HorizontalSelectorCollectionViewController
        patternSelector.items = ALL_SORT_PATTERNS.flatMap({ (ps) -> HorizontalSelectItem? in
            return HorizontalSelectItem(image: nil, title: ps.name)
        })
        
        self.addChildViewController(patternSelector)
        self.patternSelector.view.translatesAutoresizingMaskIntoConstraints = false
        self.patternContainerView.addSubview(patternSelector.view)
        self.patternSelector.view.frame = ctRect
        self.patternSelector.didMove(toParentViewController: self)
        self.patternSelector.didSelectItem = { index in
            self.pattern = ALL_SORT_PATTERNS[index]
            self.notifyChangeToDelegates()
        }
        
        let CORNER: CGFloat = 6
        self.xyPadView.layer.cornerRadius = CORNER
        self.xyPadView.clipsToBounds = true
        self.xyPadModel = XYPadModel(withXYPadView: self.xyPadView, initialValue: XYValue(x:0.5, y:0.5))
        self.xyPadModel.delegate = self
        
        self.blackThresholdView.layer.cornerRadius = CORNER
        self.whiteThresholdView.layer.cornerRadius = CORNER
        self.blackThresholdPadModel = XYPadModel(withXYPadView: self.blackThresholdView, initialValue: XYValue(x:0,y:0))
        self.blackThresholdPadModel.delegate = self
        self.whiteThresholdPadModel = XYPadModel(withXYPadView: self.whiteThresholdView, initialValue: XYValue(x:0,y:0))
        self.whiteThresholdPadModel.delegate = self
        self.updateThresholdViews()
        
    }
    
    func setXYPadBackgroundImage(_ image: UIImage) {
        self.xyPadImageView.image = image
    }
    
    func xyPad(_ view: UIView, didPanValue v: XYValue) {
        if view == self.xyPadView {
            self.setParamsWithXYPad(atPoint: v)
        }
        
    }
    
    func xyPad(_ view: UIView, didTapValue v: XYValue) {
        if view == self.xyPadView {
            self.setParamsWithXYPad(atPoint: v)
        }
    }
    
    func xyPad(_ view: UIView, changePanValue v: XYValue) {
        if view == self.xyPadView {
            let bounds = self.xyPadView.bounds
            self.xyLabel.center = CGPoint(x: v.x * bounds.width, y: v.y * bounds.height )
        }else if view == self.blackThresholdView {
            let b = UInt8(v.x * 255)
            if b < self.whiteThresholdValue {
                self.blackThresholdValue = b
                self.updateThresholdViews()
            }
        }else if view == self.whiteThresholdView {
            let w = UInt8(v.x * 255)
            if w > self.blackThresholdValue {
                self.whiteThresholdValue = w
                self.updateThresholdViews()
            }
        }
    }
    
    func updateThresholdViews() {
        self.blackThresholdLebel.text = "black: \(self.blackThresholdValue)"
        self.whiteThresholdLabel.text = "white: \(self.whiteThresholdValue)"
        self.blackThresholdView.backgroundColor = UIColor(white: CGFloat(self.blackThresholdValue)/255.0, alpha: 0.2)
        self.whiteThresholdView.backgroundColor = UIColor(white: CGFloat(self.whiteThresholdValue)/255.0, alpha: 0.2)
    }
    
    func setParamsWithXYPad(atPoint v: CGPoint) {
        let bounds = self.xyPadView.bounds
        self.xyLabel.center = CGPoint(x: v.x * bounds.width, y: v.y * bounds.height )
        
        self.sortAmount = Double(v.x)
        self.roughness = Double(v.y)
        Logger.log("sort amt: \(self.sortAmount), \(self.roughness)")
        
        self.notifyChangeToDelegates()
    }
    
    func notifyChangeToDelegates() {
        self.delegates.forEach({ (delegate) in
            delegate.paramValueDidChange(toParam: self.currentParameters)
        })
    }

    func updateUI (withImageSize size:CGSize) {
        
        self.sizeSelector.removeAllSegments()
        self.currentSizeOrder = []
        let toPopulate = AppConfig.MaxSize.ALL_SIZES
        
        for i in 0..<toPopulate.count {
            let s = toPopulate[i]
            self.sizeSelector.insertSegment(withTitle: "\(s.pixels)p", at: i, animated: false)
            self.currentSizeOrder.append(s)
        }
        
        var largerThanPreset = true
        for i in 0..<toPopulate.count {
            let s = toPopulate[i]
            if s.pixels > Int(max(size.width, size.height)) {
                self.sizeSelector.insertSegment(withTitle: "Actual", at: i, animated: true)
                self.currentSizeOrder.insert(.pxTrueSize, at: i)
                largerThanPreset = false
                break
            }
        }
        
        if largerThanPreset {
            self.sizeSelector.insertSegment(withTitle: "Actual", at: self.currentSizeOrder.count, animated: true)
            self.currentSizeOrder.append(.pxTrueSize)
        }
        self.sizeSelector.selectedSegmentIndex = 0
        
        
        
        self.sortOrientationSelector.selectedSegmentIndex = AppConfig.shared.sortOrientation.rawValue
        
        self.roughness = AppConfig.shared.roughnessAmount
        self.sortAmount = AppConfig.shared.sortAmount
        let xyLoc = CGPoint(x: CGFloat(self.sortAmount * Double(self.xyPadView.bounds.width)),
                            y: CGFloat(self.roughness * Double(self.xyPadView.bounds.height)))
        self.xyLabel.center = xyLoc
        
        self.patternSelector.collectionView?.selectItem(at: IndexPath(row:0, section:0), animated: false, scrollPosition: .centeredHorizontally)
        self.sorterSelector.collectionView?.selectItem(at: IndexPath(row:0, section:0), animated: false, scrollPosition: .centeredHorizontally)
        self.sorter = ALL_SORTERS[0]
        self.pattern = ALL_SORT_PATTERNS[0]
    }
    
    @IBAction func didSelectSize(_ sender: Any) {
        let index = self.sizeSelector.selectedSegmentIndex
        let selected = self.currentSizeOrder[index]
        Logger.log("render size: \(selected)")
        self.notifyChangeToDelegates()
    }
    
    @IBAction func didSelectSortOrientation(_ sender: Any) {
        
        let index = self.sortOrientationSelector.selectedSegmentIndex
        if let orientation = SortOrientation(rawValue: index) {
            AppConfig.shared.sortOrientation = orientation
            Logger.log("set sort orientation: \(orientation)")
        }
        self.notifyChangeToDelegates()
    }
}
