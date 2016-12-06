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
    
    var showingThumbnailView = true
    var patternPreviewsSelector: HorizontalSelectorCollectionViewController!
    var previewItems = [HorizontalSelectItem]()
    var selectedImage: UIImage?
    var selectedSorterIndex = 0
    let CORNER_RADIUS: CGFloat = 8
    
    var firstLaunch = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupPatternSelector()
        self.setupThumbnails()
        self.setupSizeSelector()
        self.consoleTextView.alpha = 0.3
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.firstLaunch {
            if let defaultImage = UIImage.loadJPEG(with: "defaultImage") {
                self.setSelected(image: defaultImage)
            }
            self.firstLaunch = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func setSelected(image: UIImage) {
        self.setProgressView(hidden: false)
        self.hidePredictionView()
        self.selectedImage = image
        self.thumbnailView.image = image
        self.backgroundImageView.image = image
        
        
        self.patternPreviewsSelector.collectionView?.reloadData()
        
        let fitSize = image.size.fit(maxPixels: Int(self.view.bounds.width - 16))
        self.constraintThumbnailWidth.constant = fitSize.width
        self.constraintThumbnailHeight.constant = fitSize.height
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
        self.patternPreviewsSelector.items = []
        self.patternPreviewsSelector.collectionView?.reloadData()
        
        DispatchQueue.global().async {
            let previews = SortingPreview().generatePreviews(with: image, progress: {
                progress in
                DispatchQueue.main.async {
                    self.progressView.progress = progress
                }
            })!
            
            self.patternPreviewsSelector.items = previews
            self.previewItems = previews
            
            DispatchQueue.main.async {
                self.patternPreviewsSelector.collectionView?.reloadData()
                self.selectedSorterIndex = 0
                self.hidePredictionView()
                completion()
            }
        }
        
        
    }
    
    fileprivate func setProgressView(hidden: Bool) {
        self.view.isUserInteractionEnabled = hidden
        
        let endAlphaStartbutton:CGFloat = hidden ? 1 : 0
        let endAlphaProgressBar:CGFloat = hidden ? 0 : 1
        UIView.animate(withDuration: 0.25, animations: {
            self.startSortButton.alpha = endAlphaStartbutton
            self.progressView.alpha = endAlphaProgressBar
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
        let index = self.sortDirectionSelector.selectedSegmentIndex
        if let orientation = SortOrientation(rawValue: index) {
            AppConfig.shared.sortOrientation = orientation
            Logger.log("set sort orientation: \(orientation)")
        }
    }
    
    @IBAction func didPressSort(_ sender: Any) {
        
        guard let image = self.selectedImage else {
            Logger.log("no image!")
            return
        }
        let sorter = PixelSorterFactory.ALL_SORTERS[self.selectedSorterIndex]
        let sortParam = SortParam(motionAmount: 0, sortAmount: 0.5, sorter: sorter, pattern: PatternClassic())
        guard let output = PixelSorting.sorted(image: image, sortParam: sortParam, progress: {
            progress in
//                Logger.log("sorting step: \(progress)")
            self.progressView.progress = Float(progress)
        }) else {
            Logger.log("Sorting failed.")
            return
        }
        
        UIImageWriteToSavedPhotosAlbum(output, nil, nil, nil)
    }
    
    fileprivate func setupSizeSelector() {
        self.sizeSelector.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Silom", size: 12) as Any], for: .normal)
        if let mp = AppConfig.shared.maxPixels {
            for i in 0..<AppConfig.MaxSize.ALL_SIZES.count {
                let test = AppConfig.MaxSize.ALL_SIZES[i]
                if mp.pixels == test.pixels {
                    self.sizeSelector.selectedSegmentIndex = i
                }
            }
        }
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
        self.thumbnailLabel.text = "Prediction - \(sorter.name)"
        UIView.animate(withDuration: 0.5) {
            self.predictionView.alpha = 1
            self.thumbnailLabel.alpha = 1
        }
    }
    @objc fileprivate func hidePredictionView () {
        Logger.log("hide prediction view")
        self.thumbnailLabel.alpha = 0
        self.thumbnailLabel.text = "Original"
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
