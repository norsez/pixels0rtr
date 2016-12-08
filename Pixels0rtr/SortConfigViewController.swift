//
//  SortConfigViewController.swift
//  Pixels0rtr
//
//  Created by norsez on 12/5/16.
//  Copyright © 2016 Bluedot. All rights reserved.
//

import UIKit

class SortConfigViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    @IBOutlet var constraintThumbnailWidth: NSLayoutConstraint!
    
    @IBOutlet var constraintThumbnailHeight: NSLayoutConstraint!
    @IBOutlet weak var thumbnailLabel: UILabel!
    @IBOutlet weak var thumbnailBackgroundView: UIView!
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var selectImageButton: UIButton!
    @IBOutlet var thumbnailView: UIImageView!
    @IBOutlet var containerViewForPatternPreviews: UIView!
    @IBOutlet weak var predictionView: UIImageView!
    @IBOutlet weak var sizeSelector: UISegmentedControl!
    @IBOutlet weak var sortDirectionSelector: UISegmentedControl!
    
    @IBOutlet var startSortButton: UIButton!
    @IBOutlet var progressView: UIProgressView!
    @IBOutlet weak var consoleTextView: UITextView!
    
    @IBOutlet weak var sortAmountLabel: UILabel!
    @IBOutlet weak var sortAmountSlider: UISlider!
    var showingThumbnailView = true
    var patternPreviewsSelector: HorizontalSelectorCollectionViewController!
    var previewItems = [HorizontalSelectItem]()
    var selectedImage: UIImage?
    var selectedSorterIndex = 0
    
    let CORNER_RADIUS: CGFloat = 8
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupPatternSelector()
        self.setupThumbnails()
        self.setupSizeSelector()
        self.consoleTextView.alpha = 0.3
        self.thumbnailLabel.text = "…"
        let controls: [UIView] = [self.startSortButton, self.sortDirectionSelector, self.progressView, self.sortAmountSlider, self.sizeSelector, self.thumbnailLabel, self.sortAmountLabel]
        for c in controls {
            c.alpha = 0.1
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let defaultImage = UIImage.loadJPEG(with: "defaultImage") else {
            Logger.log("defaultImage.jpg can't be found")
            return
        }
        if AppConfig.shared.isNotFirstLaunch == false {
            self.setSelected(image: defaultImage)
            AppConfig.shared.isNotFirstLaunch = true
        }else {
            self.backgroundImageView.image = defaultImage
        }
        
        self.sortAmountSlider.value = Float(AppConfig.shared.sortAmount)
        self.sortDirectionSelector.selectedSegmentIndex = AppConfig.shared.sortOrientation.rawValue
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    
    var thumbnailSize: Int {
        let width = Int(self.view.bounds.width)
        let height = Int(self.view.bounds.height)
        if height == 640 {
            return 176
        }else if width == 320 {
            return 280
        }else if width == 375 {
            return 320
        }else {
            return width - 16
        }
    }
    
    func setSelected(image: UIImage) {
        self.setProgressView(hidden: false)
        self.hidePredictionView()
        self.selectedImage = image
        self.thumbnailView.image = image
        self.backgroundImageView.image = image
        self.thumbnailLabel.text = "…"
        self.patternPreviewsSelector.collectionView?.reloadData()
        
        let fitSize = image.size.fit(maxPixels: self.thumbnailSize)
        self.constraintThumbnailWidth.constant = fitSize.width
        self.constraintThumbnailHeight.constant = fitSize.height
        
        
        for m in 0..<AppConfig.MaxSize.ALL_SIZES.count - 1 {
            let mz = AppConfig.MaxSize.ALL_SIZES[m]
            let canRender = self.selectedImage?.canRender(atMaxSize: mz) ?? false
            self.sizeSelector.setEnabled( canRender, forSegmentAt: m)
        }
        
        if !self.sizeSelector.isEnabledForSegment(at: AppConfig.shared.maxPixels.rawValue) {
            var foundASize = false
            for m in 0..<AppConfig.MaxSize.ALL_SIZES.count - 1 {
                let mz = AppConfig.MaxSize.ALL_SIZES[m]
                let canRender = self.selectedImage?.canRender(atMaxSize: mz) ?? false
                if  canRender {
                    self.sizeSelector.selectedSegmentIndex = m
                    AppConfig.shared.maxPixels = mz
                    foundASize = true
                    break
                }
            }
            
            //at this point, resort to full size
            if !foundASize {
            self.sizeSelector.selectedSegmentIndex = self.sizeSelector.numberOfSegments - 1
            AppConfig.shared.maxPixels = AppConfig.MaxSize.pxTrueSize
            }
        }
        
        
        UIView.animate(withDuration: 1, animations: {
            self.view.layoutIfNeeded()
        }, completion: {
            finished in
            
            self.updatePreviews(withImage: image, completion:{
                self.setProgressView(hidden: true)
            })
        })
        
        
        
    }
    
    fileprivate func updatePreviews (withImage image:UIImage, completion: @escaping ()->Void) {
        
        let progressBlock = { p in
            self.updatePregressInMainThread(p)
        }
        
        DispatchQueue.global().async {
            let previews = SortingPreview().generatePreviews(with: image, progress:progressBlock)!
            
            self.patternPreviewsSelector.items = previews
            self.previewItems = previews
            
            DispatchQueue.main.async {
                self.patternPreviewsSelector.collectionView?.reloadData()
                self.selectedSorterIndex = 0
                self.predictionView.image = previews.first?.image
                self.showPredictionView()
                
                completion()
            }
        }
    }
    
    @IBAction func sortAmountValueDidChange(_ sender: Any) {
        self.setProgressView(hidden:  false)
        AppConfig.shared.sortAmount = Double(self.sortAmountSlider.value)
        Logger.log("sort amount did change: \(self.sortAmountSlider.value)")
        if let image = self.selectedImage {
            self.updatePreviews(withImage: image, completion: {
                self.setProgressView(hidden: true)
            })
        }
        
    }
    
    fileprivate func setProgressView(hidden: Bool) {
        self.view.isUserInteractionEnabled = hidden
        
        let endAlpha:CGFloat = hidden ? 1 : 0.15
        
        let endAlphaStartbutton:CGFloat = hidden ? 1 : 0
        let endAlphaProgressBar:CGFloat = hidden ? 0 : 1
        UIView.animate(withDuration: 0.25, animations: {
            self.startSortButton.alpha = endAlphaStartbutton
            self.progressView.alpha = endAlphaProgressBar
            
            self.sortAmountSlider.alpha = endAlpha
            self.sizeSelector.alpha = endAlpha
            self.patternPreviewsSelector.view.alpha = endAlpha
            self.sortDirectionSelector.alpha = endAlpha
            self.sortAmountLabel.alpha = endAlpha
            self.selectImageButton.alpha = endAlpha
            
        })
    }

    
    func didSelectItem(atIndex index: Int) {
        self.selectedSorterIndex = index
        self.predictionView.image = self.previewItems[index].image

        UIView.animate(withDuration: 0.05, animations: {
          self.predictionView.alpha = 0
        }, completion: { finished in
          self.showPredictionView()
        })
    }
    
    @IBAction func didPressSelectImage(_ sender: Any) {
        Logger.log("select a new image…")
        let picker = UIImagePickerController()
        picker.view.backgroundColor = UIColor.black
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    
    @IBAction func didPressSizeSelector(_ sender: Any) {
        let index = self.sizeSelector.selectedSegmentIndex
        let selected = AppConfig.MaxSize.ALL_SIZES[index]
        AppConfig.shared.maxPixels = selected
        Logger.log("render size: \(selected)")
    }
    
    @IBAction func didSelectSortDirection(_ sender: Any) {
        self.setProgressView(hidden: false)
        let index = self.sortDirectionSelector.selectedSegmentIndex
        if let orientation = SortOrientation(rawValue: index) {
            AppConfig.shared.sortOrientation = orientation
            Logger.log("set sort orientation: \(orientation)")
        }
        if let image = self.selectedImage {
            self.updatePreviews(withImage:image , completion: {
                self.setProgressView(hidden: true)
            })
        }
    }
    
    @IBAction func didPressSort(_ sender: Any) {
        
        guard let image = self.selectedImage else {
            Logger.log("no image!")
            return
        }
        
        let SELECTED_SORTER_INDEX = self.selectedSorterIndex
        
        let sorter = PixelSorterFactory.ALL_SORTERS[SELECTED_SORTER_INDEX]
        let pattern = PatternClassic()
        pattern.sortOrientation = AppConfig.shared.sortOrientation
        let sortAmount = AppConfig.shared.sortAmount
        let sortParam = SortParam(motionAmount: 0, sortAmount: sortAmount, sorter: sorter, pattern: pattern)
        
        self.setProgressView(hidden: false)
        self.progressView.progress = 0.01
        let progressBlock = { p in self.updatePregressInMainThread(p) }
        DispatchQueue.global().async {
            
            var imageToSort = image
            let selectedSize = AppConfig.shared.maxPixels.pixels
            if (selectedSize != 0) {
               imageToSort = imageToSort.resize(byMaxPixels: selectedSize)!
            }
            
            sortParam.pattern.initialize(withWidth: Int(imageToSort.size.width), height: Int(imageToSort.size.height), sortParam: sortParam)
            
            guard let output = PixelSorting.sorted(image: imageToSort, sortParam: sortParam, progress: progressBlock) else {
                Logger.log("Sorting failed.")
                return
            }
            
            
            DispatchQueue.main.async {
                UIImageWriteToSavedPhotosAlbum(output, nil, nil, nil)
                self.setProgressView(hidden: true)
                var item = self.previewItems[SELECTED_SORTER_INDEX]
                item.image = output
                self.previewItems[SELECTED_SORTER_INDEX] = item
                self.patternPreviewsSelector.items = self.previewItems
                self.patternPreviewsSelector.collectionView?.reloadData()
                self.predictionView.image = output
                self.showPredictionView()
                
            }
            
        }
        
    }
    
    fileprivate func setupSizeSelector() {
        self.sizeSelector.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Silom", size: 12) as Any], for: .normal)
        self.sizeSelector.selectedSegmentIndex = AppConfig.shared.maxPixels.rawValue
    }
    
    fileprivate func setupThumbnails () {
        self.thumbnailView.layer.masksToBounds = true
        self.thumbnailView.layer.cornerRadius = CORNER_RADIUS
        self.predictionView.layer.masksToBounds = true
        self.predictionView.layer.cornerRadius = CORNER_RADIUS
        self.thumbnailBackgroundView.layer.cornerRadius = CORNER_RADIUS
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(showPredictionView))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        self.thumbnailView.addGestureRecognizer(tap)
        self.thumbnailView.isUserInteractionEnabled = true
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(hidePredictionView))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        self.predictionView.addGestureRecognizer(tap2)
        self.predictionView.isUserInteractionEnabled = true
    }
    
    @objc fileprivate func showPredictionView () {
        Logger.log("show prediction view")
        self.thumbnailLabel.alpha = 0
        let sorter = PixelSorterFactory.ALL_SORTERS[self.selectedSorterIndex]
        self.thumbnailLabel.text = "low-res preview - \(sorter.name)"
        UIView.animate(withDuration: 0.5) {
            self.predictionView.alpha = 1
            self.thumbnailLabel.alpha = 1
        }
    }
    @objc fileprivate func hidePredictionView () {
        Logger.log("hide prediction view")
        self.thumbnailLabel.alpha = 0
        var sizeString = ""
        if let img = self.selectedImage {
            let size = img.size
            let width = Int(size.width)
            let height = Int(size.height)
            sizeString = "\(width)x\(height)"
        }
        self.thumbnailLabel.text = "Original \(sizeString)"
        UIView.animate(withDuration: 0.5) {
            self.predictionView.alpha = 0
            self.thumbnailLabel.alpha = 1
        }
        
    }
    
    fileprivate func setupPatternSelector() {
        self.patternPreviewsSelector = storyboard?.instantiateViewController(withIdentifier: "patternSelecter") as! HorizontalSelectorCollectionViewController
        if let layout = self.patternPreviewsSelector.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
            let ITEMS_PER_PAGE = CGFloat(3.0)
            let WIDTH_SELECTOR = self.containerViewForPatternPreviews.frame.size.width
            let HEIGHT_SELECTOR = self.containerViewForPatternPreviews.frame.size.height
            let ITEM_SIZE = CGSize(width: WIDTH_SELECTOR/ITEMS_PER_PAGE, height: HEIGHT_SELECTOR/ITEMS_PER_PAGE)
            layout.itemSize = ITEM_SIZE
            layout.estimatedItemSize = ITEM_SIZE
            layout.scrollDirection = .vertical
        }
        self.addChildViewController(self.patternPreviewsSelector)
        self.patternPreviewsSelector.view.frame = CGRect(x: 0, y: 0, width: self.containerViewForPatternPreviews.frame.size.width, height: self.containerViewForPatternPreviews.frame.size.height)
        self.containerViewForPatternPreviews.addSubview(self.patternPreviewsSelector.view)
        self.patternPreviewsSelector.didMove(toParentViewController: self)
        self.patternPreviewsSelector.didSelectItem = { index in
            self.didSelectItem(atIndex: index)
        }
        
    }
    
    
    //MARK: progress bar
    
    
    func updatePregressInMainThread(_ progress:Float) {
        DispatchQueue.main.async {
            self.progressView.progress = Float(progress)
        }
    }
    
    
    //MARK: image picker
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.dismiss(animated: true) {
            guard let img = info[UIImagePickerControllerOriginalImage] as? UIImage else {
                Logger.log("none selected")
                return
            }
            Logger.log("original size: \(img.size)")
            self.setSelected(image: img)
        }
    }
}
