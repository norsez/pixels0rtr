//
//  SortConfigViewController.swift
//  Pixels0rtr
//
//  Created by norsez on 12/5/16.
//  Copyright © 2016 Bluedot. All rights reserved.
//

import UIKit
import AssetsLibrary

class SortConfigViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,
SortParamUIViewControllerDelegate, SortLoupeViewDelegate{
    @IBOutlet var constraintThumbnailWidth: NSLayoutConstraint!
    
    @IBOutlet var constraintThumbnailHeight: NSLayoutConstraint!
    @IBOutlet weak var thumbnailLabel: UILabel!
    @IBOutlet weak var thumbnailBackgroundView: UIView!
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var selectImageButton: UIButton!
    @IBOutlet var constraintToastY: NSLayoutConstraint!
    @IBOutlet var toastLabel: UILabel!
    @IBOutlet var startSortButton: UIButton!
    @IBOutlet var progressView: UIProgressView!
    @IBOutlet weak var consoleTextView: UITextView!
    @IBOutlet weak var controlScrollView: UIScrollView!
    @IBOutlet weak var sortLoupeView: SortLoupeView!
    
    var showingThumbnailView = true
    var paramController: SortParamUIViewController!
    var selectedImage: UIImage?
    let CORNER_RADIUS: CGFloat = 8
    
    let previewEngine = SortingPreview()
    var unsavedImage: UIImage?
    var saveUnsavedImageOnAppear = false
    
    var toast: ToastViewController?
    
    var isFreeVersion : Bool {
        get {
            return AppConfig.shared.isFreeVersion
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupParamControllerView()
        self.setupThumbnails()
        
        self.toast = self.storyboard?.instantiateViewController(withIdentifier: "ToastViewController") as? ToastViewController
        
        self.consoleTextView.alpha = 0.3
        self.thumbnailLabel.text = "…"
        #if DEBUG
            let fourtaps = UITapGestureRecognizer(target: self, action: #selector(displayDebugView))
            fourtaps.numberOfTapsRequired = 4
            self.view.addGestureRecognizer(fourtaps)
        #endif
        
        self.controlScrollView.alpha = 0
        self.progressView.alpha = 0
        self.startSortButton.alpha = 0
        
        NotificationCenter.default.addObserver(self, selector: #selector(storeDidPurchase), name: .onStoreDidPurchase, object: nil)
        
    }
    
    func setupParamControllerView() {
        
        self.paramController = self.storyboard?.instantiateViewController(withIdentifier: "sortParamUI") as! SortParamUIViewController
        
        self.paramController.delegates.append( self )
        self.addChildViewController(self.paramController)
        let containerSize = self.controlScrollView.bounds
        var adaptedSize = self.paramController.view.bounds
        adaptedSize.size.width = containerSize.size.width
        adaptedSize.size.height = self.paramController.totalHeight
        adaptedSize.origin = CGPoint.zero
        self.paramController.view.frame = adaptedSize
        
        self.controlScrollView.addSubview(self.paramController.view)
        self.controlScrollView.contentSize = adaptedSize.size
        self.paramController.didMove(toParentViewController: self)
        
        #if DEBUG
            //            self.controlScrollView.backgroundColor
        #endif
        
    }
    
    func showToast(withText text: String) {
        self.toast?.showToast(withText: text, onViewController: self)
    }
    
    
    func displayDebugView () {
        if let tv = self.storyboard?.instantiateViewController(withIdentifier: "TestViewController") as? TestViewController {
            self.navigationController?.pushViewController(tv, animated: true)
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
            if self.backgroundImageView.image == nil {
                self.backgroundImageView.image = defaultImage
            }
        }
        
        
        //        if let imv = UIView.animatedPixelsortedImageView(fromRect: CGRect(x:20,y:300,width:100,height: 120), steps:10) {
        //            imv.frame = CGRect(x: 100, y: 50, width: 100, height: 12)
        //            self.view.addSubview(imv)
        //            imv.animationDuration = 5
        //            imv.animationRepeatCount = 100
        //            imv.startAnimating()
        //        }
        
        //        let snapshot = UIScreen.main.snapshotView(afterScreenUpdates: false)
        //        UIGraphicsBeginImageContextWithOptions(snapshot.bounds.size, view.isOpaque, 0.0)
        //        let context = UIGraphicsGetCurrentContext()!
        //        let focusRect = CGRect(x: 64, y: 64, width: 100, height: 100)
        //        snapshot.drawHierarchy(in: focusRect, afterScreenUpdates: true)
        //        UIGraphicsEndImageContext();
        //        let c = context.makeImage()!
        //        let drawn = UIImage(cgImage: c)
        //        let imv = UIImageView(image: drawn)
        //        var f = focusRect
        //        f.origin = CGPoint(x:59, y:222)
        //        imv.frame = f
        //        self.view.addSubview(imv)
        
        if self.saveUnsavedImageOnAppear {
            if let image = self.unsavedImage {
                manageOutputImage(image)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    
    var thumbnailSize: Int {
        let width = Int(self.view.bounds.width)
        
        if width == 320 {
            return 240
        }else if width == 375 {
            return 320
        }else {
            return width - 16
        }
    }
    
    func setSelected(image loadedImage: UIImage) {
        self.setProgressView(hidden: false)
        self.sortLoupeView.showImage(image: nil)
        self.previewEngine.clearPreviews()
        let image = loadedImage.fixedOrientation()
        
        self.selectedImage = image
        self.backgroundImageView.image = image
        self.thumbnailLabel.text = "…"
        self.paramController.updateUI(withImageSize: image.size)
        
        let fitSize = image.size.fit(maxPixels: self.thumbnailSize)
        self.constraintThumbnailWidth.constant = fitSize.width
        self.constraintThumbnailHeight.constant = fitSize.height
        
        UIView.animate(withDuration: 1, animations: {
            self.view.layoutIfNeeded()
        }, completion: {
            finished in
            self.paramValueDidChange(toParam: self.paramController.currentParameters)
            self.thumbnailLabel.text = "\(Int(image.size.width))x\(Int(image.size.height))"
        })
        
        Analytics.shared.logSelectImage(withActualSize: loadedImage.size)
        
    }
    
    fileprivate func setProgressView(hidden: Bool, completion: (()->Void)? = nil) {
        self.view.isUserInteractionEnabled = hidden
        self.controlScrollView.isUserInteractionEnabled = hidden
        
        let endAlpha:CGFloat = hidden ? 1 : 0.15
        let endAlphaStartbutton:CGFloat = hidden ? 1 : 0
        let endAlphaProgressBar:CGFloat = hidden ? 0 : 1
        
        
        
        UIView.animate(withDuration: 0.25, animations: {
            self.startSortButton.alpha = endAlphaStartbutton
            self.progressView.alpha = endAlphaProgressBar
            self.controlScrollView.alpha = endAlpha
            self.selectImageButton.alpha = endAlpha
        }, completion: {
            finished in
            if finished {
                if let c = completion {
                    c()
                }
            }
            
        })
    }
    
    func paramValueDidChange(toParam sp: SortParam) {
        self.updatePreview()
    }
    func loupeDidMove(toLocation loc: XYValue) {
        
        self.updatePreview()
    }
    
    fileprivate func updatePreview () {
        if let image = self.selectedImage {
            self.setProgressView(hidden: false)
            DispatchQueue.global().async {
                self.previewEngine.updatePreview(forImage: image, withSortParam: self.paramController.currentParameters, loupeOrigin: self.sortLoupeView.currentOrigin, progress: { (v) in
                    self.updatePregressInMainThread(v)
                }, completion: { (previewImage, sortedRect) in
                    DispatchQueue.main.async {
                        self.setProgressView(hidden: true)
                        if let pv = previewImage{
                            self.paramController.setXYPadBackgroundImage(pv)
                            self.sortLoupeView.showImage(image: pv)
                            self.thumbnailLabel.text = "lo-fi preview"
                        }
                    }
                    
                })
            }
        }
    }
    
    @IBAction func didPressSelectImage(_ sender: Any) {
        Logger.log("select a new image…")
        let picker = UIImagePickerController()
        
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
        picker.view.backgroundColor = UIColor.black
        picker.navigationBar.barStyle = .blackTranslucent
        let font = UIFont(name: "Silom", size: 16)!
        let fontColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0.9)
        picker.navigationBar.titleTextAttributes = [NSFontAttributeName: font, NSForegroundColorAttributeName: fontColor]
        self.controlScrollView.flashScrollIndicators()
        
    }
    
    
    
    @IBAction func didPressSort(_ sender: Any) {
        
        guard let image = self.selectedImage else {
            Logger.log("no image!")
            return
        }
        
        
        let sortParam = self.paramController.currentParameters
        
        self.setProgressView(hidden: false)
        self.progressView.progress = 0.01
        let progressBlock = { p in self.updatePregressInMainThread(p) }
        DispatchQueue.global().async {
            
            guard let imageToSort = image.resize(toFitMaxPixels: sortParam.maxPixels) else {
                Logger.log("failed to resize to fix \(sortParam.maxPixels)")
                return
            }
            
            sortParam.pattern.initialize(withWidth: Int(imageToSort.size.width), height: Int(imageToSort.size.height), sortParam: sortParam)
            let sortedResult = PixelSorting.sorted(image: imageToSort, sortParam: sortParam, progress: progressBlock)
            guard let output = sortedResult.output else {
                Logger.log("Sorting failed.")
                return
            }
            
            
            DispatchQueue.main.async {
                self.toast?.showToast(withPixelSortingStats: sortedResult.stats, onViewController: self) {
                    self.manageOutputImage(output)
                    self.sortLoupeView.showImage(image: output, inLoupeWithImage: output)
                    self.thumbnailLabel.text = "full-res output"
                    Analytics.shared.logSort(withSortParam: sortParam)
                }
            }
            
        }
        
    }
    
    
    func manageOutputImage(_ output:UIImage) {
        
        if AppConfig.shared.isFreeVersion && max(output.size.width,output.size.height) > 600 {
            self.performSegue(withIdentifier: "showUnlock", sender: output)
            self.setProgressView(hidden: true, completion: {})
            self.unsavedImage = output
            
        }else {
            
            UIImageWriteToSavedPhotosAlbum(output, nil, nil, nil)
            self.setProgressView(hidden: true, completion: {
                self.showToastMessage("Saved\nto\nCamera Roll")
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showUnlock" {
            if let image = sender as? UIImage {
                if let ctrl = segue.destination as? UnlockViewController {
                    ctrl.image = image
                }
                
            }
        }
    }
    
    
    
    fileprivate func setupThumbnails () {
//        self.thumbnailView.layer.masksToBounds = true
//        self.thumbnailView.layer.cornerRadius = CORNER_RADIUS
//        self.predictionView.layer.masksToBounds = true
//        self.predictionView.layer.cornerRadius = CORNER_RADIUS
        
        
//        let tap = UITapGestureRecognizer(target: self, action: #selector(showPredictionView))
//        tap.numberOfTapsRequired = 1
//        tap.numberOfTouchesRequired = 1
//        self.thumbnailView.addGestureRecognizer(tap)
//        self.thumbnailView.isUserInteractionEnabled = true
//        
//        let tap2 = UITapGestureRecognizer(target: self, action: #selector(hidePredictionView))
//        tap.numberOfTapsRequired = 1
//        tap.numberOfTouchesRequired = 1
//        self.predictionView.addGestureRecognizer(tap2)
//        self.predictionView.isUserInteractionEnabled = true
        
        self.thumbnailBackgroundView.layer.cornerRadius = CORNER_RADIUS
        self.sortLoupeView.delegate = self
        
    }
    
    
    
    func showToastMessage(_ m:String, completion: (()->Void)? = nil) {
        
        self.toastLabel.text = m
        self.constraintToastY.constant = 32
        self.view.layoutIfNeeded()
        
        let appear = {
            self.startSortButton.alpha = 0
            self.toastLabel.alpha = 0.9
            self.view.layoutIfNeeded()
        }
        
        let blink = { (finished: Bool, completion: @escaping (Bool)->Void) in
            if !finished {
                return
            }
            UIView.setAnimationRepeatCount(5)
            UIView.animate(withDuration: 0.3, delay: 0, options: [.beginFromCurrentState, .autoreverse], animations: {
                self.toastLabel.alpha = 0.1
            }, completion: completion)
        }
        
        let moveDown = { (finished: Bool) in
            if (finished){
                self.constraintToastY.constant = -32
                UIView.animate(withDuration: 1, delay:0, options: [.beginFromCurrentState], animations: {
                    self.toastLabel.alpha = 0
                    self.startSortButton.alpha = 0.9
                    self.view.layoutIfNeeded()
                    
                }, completion: nil)
            }
        }
        
        self.constraintToastY.constant = 0
        UIView.animate(withDuration: 0.2, delay: 0.2, options: [], animations: {
            
            appear()
        }, completion: { finished in
            blink(finished, moveDown)
            if let c = completion {
                c()
            }
        })
    }
    
    
    //MARK: progress bar
    
    func updatePregressInMainThread(_ progress:Float) {
        DispatchQueue.main.async {
            self.progressView.progress = progress
        }
    }
    
    @objc fileprivate func storeDidPurchase () {
        if let _ = self.unsavedImage {
            self.saveUnsavedImageOnAppear = true
        }else {
            self.showToastMessage("Thank you! Now you save your work in high definition!")
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        SortColor.clearCache()
    }
}
