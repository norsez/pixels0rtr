//
//  PreviewSelectorCollectionViewController.swift
//  Pixels0rtr
//
//  Created by norsez on 2/25/17.
//  Copyright © 2017 Bluedot. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class PreviewGridCell: UICollectionViewCell {
    
    @IBOutlet var previewImageView: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    
    var selectedView: UIView? = nil
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.selectedView?.frame = self.bounds
    }
    
    func setSelectionMark(_ selected: Bool, animated: Bool) {
        if self.selectedView == nil {
            self.selectedView = UIView(frame: self.bounds)
            self.addSubview(self.selectedView!)
        }
        
        self.selectedView?.backgroundColor = selected ? APP_COLOR_FONT.withAlphaComponent(0.5) : UIColor.clear

    }
}

class PreviewSelectorCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    @IBOutlet var titleLabel: UILabel!
    var previewImages = [UIImage]()
    var sortParams = [SortParam]()
    var imageToPreview: UIImage?
    var _currentSortParam: SortParam?
    
    var modeIsAddToBatch = false
    var selectedSortParamItems = [Int]()
    
    var currentSortParam: SortParam? {
        get {
            return self._currentSortParam
        }
        
        set(v) {
            SamplePreviewEngine.shared.lastImages = []
            SamplePreviewEngine.shared.lastParams = []
            _currentSortParam = v
        }
    }
    
    
    var didSelectItem: ((SortParam?)->Void)?
    var randomizeButton: UIBarButtonItem?
    var doneButton: UIBarButtonItem?
    var addToBatchButton: UIBarButtonItem?
    var currentCatalogButton: UIBarButtonItem?
    let NUM_PREVIEWS = 24
    
    //MARK: for mass previews
    fileprivate var aborted = false
    fileprivate var busy = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.titleView = self.titleLabel
        if let label = self.navigationItem.titleView as? UILabel{
            label.font = APP_FONT
            label.textColor = APP_COLOR_FONT
        }
        
        self.currentCatalogButton = UIBarButtonItem(title: "[ 123 ]", style: .plain, target: self, action: #selector(didPressRefresh(sender:)))
        self.randomizeButton = UIBarButtonItem(title: "[ ∞ ]", style: .plain, target: self, action: #selector(didPressRefresh(sender:)))
        self.doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissSelf))
        self.navigationItem.leftBarButtonItems = [self.randomizeButton!, self.currentCatalogButton!]
        
        #if DEBUG
            self.addToBatchButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addToBatch))
            self.navigationItem.rightBarButtonItems = [self.doneButton!, self.addToBatchButton!]
        #else
            self.navigationItem.rightBarButtonItem = self.doneButton
        #endif
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        guard let _ = self.currentSortParam else {
            fatalError("must set currentSortParam")
        }
        
        Analytics.shared.logScreen("Random Previews")
        
        let labMode = AppConfig.shared.labMode
        if labMode == .randomized {
            self.didPressRefresh(sender: self.randomizeButton!)
        }else if labMode == .xyPad {
            self.didPressRefresh(sender: self.currentCatalogButton!)
        }
        
    }
    
    func addToBatch() {
        self.modeIsAddToBatch = !self.modeIsAddToBatch
        self.collectionView?.allowsMultipleSelection = self.modeIsAddToBatch
        self.collectionView?.backgroundColor = self.modeIsAddToBatch ? APP_COLOR_FONT : UIColor.black
        
        if !self.modeIsAddToBatch {
            
            guard let imagePath = AppConfig.shared.lastImagePath else {
                Logger.log("imagePath can't be nil")
                return
            }
            
            
            self.selectedSortParamItems.forEach({ (item) in
                do {
                    try self.sortParams[item].save(withImageFilePath: imagePath)
                }catch {
                    Logger.log("\(error)")
                }
            })
            
            self.selectedSortParamItems = []
            self.collectionView?.reloadData()
        }
    }
    
    func didPressRefresh (sender: Any) {
        
        SamplePreviewEngine.shared.lastImages = []
        SamplePreviewEngine.shared.lastParams = []
        
        guard let obj = sender as? UIBarButtonItem else {
            return
        }
        
        if obj === self.currentCatalogButton {
            self.sortParams = SamplePreviewEngine.shared.paramCatalog(withSortParam:currentSortParam!)
            AppConfig.shared.labMode = .xyPad
        }else if obj === self.randomizeButton {
            let params = SamplePreviewEngine.shared.sampleSortParams
            self.sortParams = SamplePreviewEngine.shared.randomizedParams(withParams: params, count: self.NUM_PREVIEWS)
            AppConfig.shared.labMode = .randomized
        }
        
        self.createPreviews(withParams: self.sortParams)
    }
    
    func dismissSelf() {
        self.aborted = true
        if let ctrl = self.presentingViewController {
            ctrl.dismiss(animated: true, completion: nil)
        }else {
            let _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    func createPreviews (withParams params: [SortParam]) {
        
        guard let image = self.imageToPreview else {
            Logger.log("no image to preview")
            return
        }
        
        if SamplePreviewEngine.shared.lastImages.count > 0 {
            self.sortParams = SamplePreviewEngine.shared.lastParams
            self.previewImages = SamplePreviewEngine.shared.lastImages
            self.collectionView?.reloadData()
            self.titleLabel.text = "Pick one…"
            return
        }
        
        
        self.titleLabel.text = "Creating previews…"
        self.randomizeButton?.isEnabled = false
        self.currentCatalogButton?.isEnabled = false
        
        self.previewImages = []
        self.collectionView?.reloadData()
        
        self.busy = true
        self.aborted = false
        DispatchQueue.global(qos: .default).async {
            self.aborted = false
            
            let pf = NumberFormatter()
            pf.numberStyle = .percent
            pf.maximumFractionDigits = 0
            SamplePreviewEngine.shared.createPreviews(withParams: self.sortParams, forImage: image,
                                                progress: { (image, sortParam, progressValue) in
                
                DispatchQueue.main.async {
                    self.collectionView?.performBatchUpdates({ 
                        
                        self.collectionView?.performBatchUpdates({ 
                            self.previewImages.append(image)
                            self.sortParams.append(sortParam)
                            self.collectionView?.insertItems(at: [IndexPath(item:self.previewImages.count - 1, section:0)])
                        }, completion: nil)
                    }, completion: nil)
                    self.titleLabel.text = pf.string(from: NSNumber(value: progressValue))
                }
            }, aborted: {
                return self.aborted
            }) { (images, sortParams) in
                
                DispatchQueue.main.async {
                    if let images = images {
                        self.previewImages = images
                    }
                    if let sps = sortParams {
                        self.sortParams = sps
                    }
                    
                    self.randomizeButton?.isEnabled = true
                    self.currentCatalogButton?.isEnabled = true
                    
                    self.titleLabel.text = "Pick one…"
                }
                
                self.busy = false
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.previewImages.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        if let pcell = cell as? PreviewGridCell {
            pcell.previewImageView.image = self.previewImages[indexPath.item]
            let nf = NumberFormatter()
            nf.numberStyle = .percent
            pcell.infoLabel.text = ""
            
        }
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let selected = self.selectedSortParamItems.contains(indexPath.item)
        if let cell = cell as? PreviewGridCell {
            cell.setSelectionMark(selected, animated: true)
        }
        
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if self.busy {
            return
        }
        
        self.aborted = true
        
        let cell = self.collectionView?.cellForItem(at: indexPath) as! PreviewGridCell
        if self.modeIsAddToBatch {
            
            if !self.selectedSortParamItems.contains(indexPath.item) {
                self.selectedSortParamItems.append(indexPath.item)
                cell.setSelectionMark(true, animated: true)
            }else {
                self.selectedSortParamItems = self.selectedSortParamItems.filter({ (item) -> Bool in
                    return item != indexPath.item
                })
                cell.setSelectionMark(false, animated: true)
            }
            
        }else {
            if let c = self.didSelectItem {
                let sp = self.sortParams[indexPath.item]
                AppConfig.shared.lastSortParam = sp
                Logger.log("select param: \(sp)")
                c(sp)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let s = self.view.frame.size.width/3.0 - 4
        return CGSize(width: s, height: s)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
