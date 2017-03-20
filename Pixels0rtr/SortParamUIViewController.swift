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
    func didPressLabButton()
}

class SortParamUIViewController: UIViewController, XYPadDelegate, ThresholdModelControllerDelegate {

    @IBOutlet weak var xyPadImageView: UIImageView!
    @IBOutlet weak var xyPadView: UIView!
    @IBOutlet var sizeSelector: UISegmentedControl!
    @IBOutlet var sortOrientationSelector: UISegmentedControl!
    @IBOutlet var patternContainerView: UIView!
    @IBOutlet var sorterContainerView: UIView!
    @IBOutlet var xyLabel: UILabel!
    
    @IBOutlet var thresholdPad: ThresholdControlView!
    
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
            return 640
        }
    }
    var xyPadModel: XYPadModel!
    
    var roughness: Double = 0
    var sortAmount: Double = 0
    var sorter: PixelSorter = SorterBrightness()
    var pattern: SortPattern = PatternClassic()
    
    var currentParameters: SortParam {
        get{
            let maxPixels = self.currentSizeOrder[self.sizeSelector.selectedSegmentIndex]
            var sp = SortParam(roughness: self.roughness, sortAmount: self.sortAmount, sorter: self.sorter, pattern: self.pattern, maxPixels: maxPixels)
            sp.orientation = SortOrientation(rawValue: self.sortOrientationSelector.selectedSegmentIndex)!
            sp.blackThreshold = UInt8(self.thresholdPad.model.lowerValue * 255)
            sp.whiteThreshold = UInt8(self.thresholdPad.model.upperValue * 255)
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
        
        self.thresholdPad.setDelegate(delegate: self)
        
    }
    
    @IBAction func didPressRandomize(_ sender: Any) {
        self.delegates.forEach({ (delegate) in
            delegate.didPressLabButton()
        })
    }
    
    fileprivate func randomizeParams () {

        self.sortAmount = fRandom(min:0, max:1)
        self.roughness = fRandom(min:0, max:1)
        
        let patternIndex = Int(arc4random()) % ALL_SORT_PATTERNS.count
        let sorterIndex = Int(arc4random()) % ALL_SORTERS.count
        
        self.pattern = ALL_SORT_PATTERNS[patternIndex]
        self.sorter = ALL_SORTERS[sorterIndex]
        
        var sp = SortParam(roughness: self.roughness,
                           sortAmount: self.sortAmount,
                           sorter: self.sorter,
                           pattern: self.pattern,
                           maxPixels: AppConfig.MaxSize.px600)
        sp.blackThreshold = UInt8( fRandom(min: 0, max: 0.2) * 255 )
        sp.whiteThreshold = UInt8( fRandom(min: 0.7, max: 1) * 255 )
        
        self.updateRandomParameterUI(withSortParam: sp)
        self.notifyChangeToDelegates()
    }
    
    func updateRandomParameterUI(withSortParam sp: SortParam) {
        self.thresholdPad.setLowerValue(value: Double(sp.blackThreshold) / 255)
        self.thresholdPad.setUpperValue(value: Double(sp.whiteThreshold) / 255)
        
        let patternIndex = ALL_SORT_PATTERNS.index { (p) -> Bool in
            return p.name == sp.pattern.name
        }!
        
        let sorterIndex = ALL_SORTERS.index { (sorter) -> Bool in
            return sorter.name == sp.sorter.name
        }!
        self.sorter = sp.sorter
        self.pattern = sp.pattern
        
        self.patternSelector.collectionView?.selectItem(at: IndexPath(row:patternIndex, section:0), animated: false, scrollPosition: .centeredHorizontally)
        self.sorterSelector.collectionView?.selectItem(at: IndexPath(row:sorterIndex, section:0), animated: false, scrollPosition: .centeredHorizontally)
        
        
        let xyLoc = CGPoint(x: CGFloat(sp.sortAmount * Double(self.xyPadView.bounds.height)),
                            y: CGFloat(sp.roughnessAmount * Double(self.xyPadView.bounds.width)))
        self.xyLabel.center = xyLoc
        self.sortAmount = sp.sortAmount
        self.roughness = sp.roughnessAmount
        self.sortOrientationSelector.selectedSegmentIndex = sp.orientation.rawValue
        
    }
    
    
    func valuesDidChange(lower: Double, upper: Double) {
        
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
        }
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
        
        self.thresholdPad.setLowerValue(value: 0)
        self.thresholdPad.setUpperValue(value: 1)
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
