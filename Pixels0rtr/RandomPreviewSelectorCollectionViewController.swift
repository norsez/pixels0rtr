//
//  RandomPreviewSelectorCollectionViewController.swift
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
    
}

class RandomPreviewSelectorCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    @IBOutlet var titleLabel: UILabel!
    var previewImages = [UIImage]()
    var sortParams = [SortParam]()
    var imageToPreview: UIImage?
    
    
    var didSelectItem: ((SortParam?)->Void)?
    var updatePreviewsButton: UIBarButtonItem?
    var doneButton: UIBarButtonItem?
    
    
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

        self.updatePreviewsButton = UIBarButtonItem(title: "Refresh", style: .plain, target: self, action: #selector(didPressRefresh(sender:)))
        self.doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissSelf))
        self.navigationItem.leftBarButtonItem = self.updatePreviewsButton
        self.navigationItem.rightBarButtonItem = self.doneButton
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.createPreviews()
        Analytics.shared.logScreen("Random Previews")
    }
    func didPressRefresh (sender: Any) {
        SamplePreviewEngine.shared.lastImages = []
        SamplePreviewEngine.shared.lastParams = []
        self.createPreviews()
    }
    
    func dismissSelf() {
        self.aborted = true
        if let ctrl = self.presentingViewController {
            ctrl.dismiss(animated: true, completion: nil)
        }else {
            let _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    func createPreviews () {
        
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
        self.updatePreviewsButton?.isEnabled = false
        
        self.sortParams = []
        self.previewImages = []
        self.collectionView?.reloadData()
        
        self.busy = true
        self.aborted = false
        DispatchQueue.global(qos: .default).async {
            self.aborted = false
            let NUM_PREVIEWS = 24
            
            let pf = NumberFormatter()
            pf.numberStyle = .percent
            pf.maximumFractionDigits = 0
            SamplePreviewEngine.shared.createRandomPreviews(count: NUM_PREVIEWS, forImage: image,
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
                    
                    self.updatePreviewsButton?.isEnabled = true
                    
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
            let sp = self.sortParams[indexPath.item]
            pcell.infoLabel.text = "\(sp.sorter.name) \(sp.pattern.name)"
        }
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if self.busy {
            return
        }
        
        self.aborted = true
        if let c = self.didSelectItem {
            let sp = self.sortParams[indexPath.item]
            AppConfig.shared.lastSortParam = sp
            c(sp)
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
