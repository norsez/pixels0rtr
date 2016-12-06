//
//  SortConfigViewController.swift
//  Pixels0rtr
//
//  Created by norsez on 12/5/16.
//  Copyright © 2016 Bluedot. All rights reserved.
//

import UIKit

class SortConfigViewController: UIViewController {
    
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var selectImageButton: UIButton!
    @IBOutlet var thumbnailView: UIImageView!
    @IBOutlet var containerViewForPatternPreviews: UIView!
    @IBOutlet weak var predictionView: UIImageView!
    var showingThumbnailView = true
    var patternPreviewsSelector: HorizontalSelectorCollectionViewController!
    var previewItems = [HorizontalSelectItem]()
    var selectedSorterIndex = 0
    let CORNER_RADIUS: CGFloat = 8
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupPatternSelector()
        self.setupThumbnails()
        
        if let defaultImage = UIImage.loadJPEG(with: "defaultImage") {
            self.setSelected(image: defaultImage)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func setSelected(image: UIImage) {
        self.thumbnailView.image = image
        self.backgroundImageView.image = image
        let previews = SortingPreview().generatePreviews(with: image)!
        self.patternPreviewsSelector.items = previews
        self.previewItems = previews
        self.patternPreviewsSelector.collectionView?.reloadData()
    }
    
    func didSelectItem(atIndex index: Int) {
        self.selectedSorterIndex = index
        self.predictionView.image = self.previewItems[index].image
        self.showPredictionView()
    }
    

    fileprivate func setupThumbnails () {
        self.thumbnailView.layer.masksToBounds = true
        self.thumbnailView.layer.cornerRadius = CORNER_RADIUS
        self.predictionView.layer.masksToBounds = true
        self.predictionView.layer.cornerRadius = CORNER_RADIUS

        
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
        self.predictionView.alpha = 0.9
    }
    @objc fileprivate func hidePredictionView () {
        self.predictionView.alpha = 0
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

}
