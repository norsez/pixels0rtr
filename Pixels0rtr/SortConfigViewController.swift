//
//  SortConfigViewController.swift
//  Pixels0rtr
//
//  Created by norsez on 12/5/16.
//  Copyright © 2016 Bluedot. All rights reserved.
//

import UIKit

class SortConfigViewController: UIViewController, LoggerListener, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var thumbnailLabel: UILabel!
    @IBOutlet weak var thumbnailBackgroundView: UIView!
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var selectImageButton: UIButton!
    @IBOutlet var thumbnailView: UIImageView!
    @IBOutlet var containerViewForPatternPreviews: UIView!
    @IBOutlet weak var predictionView: UIImageView!
    @IBOutlet weak var sizeSelector: UISegmentedControl!
    
    @IBOutlet weak var consoleTextView: UITextView!
    
    var showingThumbnailView = true
    var patternPreviewsSelector: HorizontalSelectorCollectionViewController!
    var previewItems = [HorizontalSelectItem]()
    var selectedSorterIndex = 0
    let CORNER_RADIUS: CGFloat = 8
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Logger.shared.addLoggerListener(self)
        self.setupPatternSelector()
        self.setupThumbnails()
        self.setupSizeSelector()
        self.consoleTextView.alpha = 0.3
        
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
        self.thumbnailLabel.text = "Prediction"
        UIView.animate(withDuration: 0.5) {
            self.predictionView.alpha = 0.9
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

    //MARK: logging
    
    
    var logBusy = false
    func didReceiveLog(_ log: String) {
        
        if logBusy {
            return
        }
        
        logBusy = true
        
        DispatchQueue.global(qos: .utility).async {
            DispatchQueue.main.async {
                
                if Logger.shared.entries.count == 0 {
                    return
                }
                
                let MAX_LINES = 30
                let last = Logger.shared.entries.count
                let first = max(last - MAX_LINES, 0)
                let entries = Logger.shared.entries[first..<last]
                let ALINGS: [NSTextAlignment] = [.center, .left, .right, .justified]
                let astr = NSMutableAttributedString()
                
                
                for t in entries {
                    let size = CGFloat( 8.0 + 17.0 * fRandom(min: 0, max: 1))
                    let font = UIFont(name:"Silom", size: size)!
                    let color = UIColor(red: CGFloat(fRandom(min: 0, max: 0.1)), green: 1, blue: CGFloat(fRandom(min: 0, max: 0.1)), alpha: CGFloat(0.02 + 0.15 * fRandom(min: 0, max: 1)))
                    let par = NSMutableParagraphStyle()
                    par.alignment = ALINGS[Int(arc4random_uniform(100)) % ALINGS.count]
                    
                    let ntr = NSAttributedString(string: "\(t)\n", attributes: [NSFontAttributeName: font, NSForegroundColorAttributeName: color, NSParagraphStyleAttributeName: par])
                    astr.append(ntr)
                }
                self.consoleTextView.attributedText = astr
                self.logBusy = false
            }
        }
    }

}
