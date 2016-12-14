//
//  SortParamUIViewController.swift
//  Pixels0rtr
//
//  Created by norsez on 12/13/16.
//  Copyright © 2016 Bluedot. All rights reserved.
//

import UIKit

protocol SortParamUIViewControllerDelegate {
    func paramValueDidChange(toParam: SortParam, shouldUpdatePreviews: Bool)
}

class SortParamUIViewController: UIViewController {

    @IBOutlet weak var xyPadImageView: UIImageView!
    @IBOutlet weak var xyPadView: UIView!
    @IBOutlet var sizeSelector: UISegmentedControl!
    @IBOutlet var sortOrientationSelector: UISegmentedControl!
    @IBOutlet var patternContainerView: UIView!
    @IBOutlet var sorterContainerView: UIView!
    @IBOutlet var xyLabel: UILabel!
    
    
    @IBOutlet var constraintBottomXYPad: NSLayoutConstraint!
    @IBOutlet var constraintTopXYPad: NSLayoutConstraint!
    @IBOutlet var constraintWidthXYPad: NSLayoutConstraint!
    @IBOutlet var constraightHeightXYPad: NSLayoutConstraint!
    var delegate: SortParamUIViewControllerDelegate?
    
    var sorterSelector: HorizontalSelectorCollectionViewController!
    var patternSelector: HorizontalSelectorCollectionViewController!
    
    var totalHeight: CGFloat {
        get {
            return self.sizeSelector.frame.maxY + 48
        }
    }
    
    var roughness: Double = 0
    var sortAmount: Double = 0
    var sorter: PixelSorter = SorterBrightness()
    var pattern: SortPattern = PatternClassic()
    
    var currentParameters: SortParam {
        get{
            var sp = SortParam(roughness: self.roughness, sortAmount: self.sortAmount, sorter: self.sorter, pattern: self.pattern)
            sp.orientation = SortOrientation(rawValue: self.sortOrientationSelector.selectedSegmentIndex)!
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
            self.delegate?.paramValueDidChange(toParam: self.currentParameters, shouldUpdatePreviews: false)
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
            self.delegate?.paramValueDidChange(toParam: self.currentParameters, shouldUpdatePreviews: false)
        }
        
        
        let xyTap = UITapGestureRecognizer(target: self, action: #selector(didTapXYPad(_:)))
        xyTap.numberOfTapsRequired = 1
        xyTap.numberOfTouchesRequired = 1
        let xyPan = UIPanGestureRecognizer(target: self, action: #selector(didPanXYPad(_:)))
        xyPan.maximumNumberOfTouches = 1
        xyPan.minimumNumberOfTouches = 1
        self.xyPadView.addGestureRecognizer(xyTap)
        self.xyPadView.addGestureRecognizer(xyPan)
        
        self.xyPadView.layer.cornerRadius = 6
        self.xyPadView.clipsToBounds = true
        
        
//        #if DEBUG
//            self.xyPadView.backgroundColor = UIColor.red
//            self.xyPadView.layer.borderColor = UIColor.blue.cgColor
//            self.xyPadView.layer.borderWidth = 1
//        #endif
    }
    
    func setXYPadBackgroundImage(_ image: UIImage) {
        self.xyPadImageView.image = image
    }
    
    func didTapXYPad(_ gr: UITapGestureRecognizer) {
        if gr.state == .ended {
            let point = gr.location(in: self.xyPadView)
            self.setParamsWithXYPad(atPoint: point, notifyDelegate: true)
        }
    }
    
    func didPanXYPad(_ gr: UIPanGestureRecognizer) {
        let point = gr.location(in: self.xyPadView)
        if gr.state == .changed {
            self.setParamsWithXYPad(atPoint: point)
        }else if gr.state == .ended {
            self.setParamsWithXYPad(atPoint: point, notifyDelegate: true)
        }
    }
    
    func setParamsWithXYPad(atPoint point: CGPoint, notifyDelegate: Bool = false) {
        if self.xyPadView.bounds.contains(point) == false {
            return
        }
        
        let bounds = self.xyPadView.bounds
        self.xyLabel.center = point
        self.sortAmount = Double(point.x)/Double(bounds.width)
        self.roughness = Double(point.y)/Double(bounds.height)
        Logger.log("sort amt: \(self.sortAmount), \(self.roughness)")
        
        if notifyDelegate {
            self.delegate?.paramValueDidChange(toParam: self.currentParameters, shouldUpdatePreviews: true)
        }
    }
    

    func updateUI (withImageSize size:CGSize) {
        
        let MAX_IMAGE_SIZE = max(size.width, size.height)
        for i in 1..<AppConfig.MaxSize.ALL_SIZES.count {
            let mp = AppConfig.MaxSize.ALL_SIZES[i]
            self.sizeSelector.setEnabled(mp.pixels <= Int(MAX_IMAGE_SIZE), forSegmentAt: i)
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
    }
    
    @IBAction func didSelectSize(_ sender: Any) {
   
        let index = self.sizeSelector.selectedSegmentIndex
        let selected = AppConfig.MaxSize.ALL_SIZES[index]
        AppConfig.shared.maxPixels = selected
        Logger.log("render size: \(selected)")
        self.delegate?.paramValueDidChange(toParam: self.currentParameters, shouldUpdatePreviews: false)
    }
    
    @IBAction func didSelectSortOrientation(_ sender: Any) {
        
        let index = self.sortOrientationSelector.selectedSegmentIndex
        if let orientation = SortOrientation(rawValue: index) {
            AppConfig.shared.sortOrientation = orientation
            Logger.log("set sort orientation: \(orientation)")
        }
        self.delegate?.paramValueDidChange(toParam: self.currentParameters, shouldUpdatePreviews: true)
    }
}
