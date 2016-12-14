//
//  SortConfigViewController.swift
//  Pixels0rtr
//
//  Created by norsez on 12/5/16.
//  Copyright © 2016 Bluedot. All rights reserved.
//

import UIKit

class SortConfigViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,
SortParamUIViewControllerDelegate{
    @IBOutlet var constraintThumbnailWidth: NSLayoutConstraint!
    
    @IBOutlet var constraintThumbnailHeight: NSLayoutConstraint!
    @IBOutlet weak var thumbnailLabel: UILabel!
    @IBOutlet weak var thumbnailBackgroundView: UIView!
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var selectImageButton: UIButton!
    @IBOutlet var thumbnailView: UIImageView!
    @IBOutlet weak var predictionView: UIImageView!
    @IBOutlet var constraintToastY: NSLayoutConstraint!
    @IBOutlet var toastLabel: UILabel!
    @IBOutlet var startSortButton: UIButton!
    @IBOutlet var progressView: UIProgressView!
    @IBOutlet weak var consoleTextView: UITextView!
    @IBOutlet weak var controlScrollView: UIScrollView!
    
    
    var showingThumbnailView = true
    var paramController: SortParamUIViewController!
    var selectedImage: UIImage?
    let CORNER_RADIUS: CGFloat = 8
    
    let previewEngine = SortingPreview()
    
    var isFreeVersion : Bool {
        get {
            return AppConfig.shared.isFreeVersion
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupThumbnails()
        self.setupParamControllerView()
        
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
        
    
    }
    
    func setupParamControllerView() {
        
        self.paramController = self.storyboard?.instantiateViewController(withIdentifier: "sortParamUI") as! SortParamUIViewController
        
        self.paramController.delegate = self
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
        self.hidePredictionView()
        let image = UIImage(cgImage: loadedImage.cgImage!, scale: 1, orientation: .up)
        
        self.selectedImage = image
        self.thumbnailView.image = image
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
            
            self.updatePreviews(withImage: image, completion:{
                self.setProgressView(hidden: true)
                self.paramController.setXYPadBackgroundImage(image)
            })
        })
        
        Analytics.shared.logSelectImage(withActualSize: loadedImage.size)
        
    }
    
    fileprivate var isUpdatingPreviews = false
    fileprivate func updatePreviews (withImage image:UIImage, completion: @escaping ()->Void) {
        
        if isUpdatingPreviews {
            return
        }
        
        isUpdatingPreviews = true
        
        let progressBlock = { p in
            self.updatePregressInMainThread(p)
        }
        
        DispatchQueue.global().async {
           self.previewEngine.generatePreviews(with: image, sortParam: self.paramController.currentParameters, progress:progressBlock)
            
            DispatchQueue.main.async {
                self.showPredictionView()
                completion()
                self.isUpdatingPreviews = false
                
            }
        }
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
            self.predictionView.alpha = endAlpha
        }, completion: {
            finished in
            if finished {
                if let c = completion {
                    c()
                }
            }
            
        })
    }

    
    func paramValueDidChange(toParam sp: SortParam, shouldUpdatePreviews: Bool) {
        
        if shouldUpdatePreviews {
            if let si = self.selectedImage {
                self.setProgressView(hidden: false)
                
                self.updatePreviews(withImage: si, completion: {
                    self.setProgressView(hidden: true)
                    self.showPredictionView()
                })
            }
        }else {
            self.showPredictionView()
        }
        
        if let pimage = self.previewEngine.previewImage(withSortParam: sp) {
            self.paramController.setXYPadBackgroundImage(pimage)
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
                self.manageOutputImage(output)
                self.previewEngine.updatePreviewImage(withImage: output, sortParam: self.paramController.currentParameters)
                self.showPredictionView()
                Analytics.shared.logSort(withSortParam: sortParam)
            }
            
        }
        
    }
    
    func manageOutputImage(_ output:UIImage) {
        
        if AppConfig.shared.isFreeVersion && AppConfig.shared.maxPixels != .px600 {
            AppConfig.shared.maxPixels = .px600
            self.performSegue(withIdentifier: "showUnlock", sender: output)
            self.setProgressView(hidden: true, completion: {})
            
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
        guard let _ = self.selectedImage else {
            return
        }
        
        let sortParam = self.paramController.currentParameters
        
        guard let currentPreviewImage  = self.previewEngine.previewImage(withSortParam: sortParam) else {
            Logger.log("no preview for \(sortParam)")
            return
        }
        self.predictionView.image = currentPreviewImage
        Logger.log("show prediction view")
        self.thumbnailLabel.alpha = 0
        
        self.thumbnailLabel.text = "lo-res preview: \(self.previewEngine.title(ofSortParam: sortParam))"
        
        
        UIView.animate(withDuration: 0.5) {
            self.predictionView.alpha = 0.85
            self.thumbnailLabel.alpha = 0.85
        }
    }
    @objc fileprivate func hidePredictionView () {
        guard let _ = self.selectedImage else {
            return
        }
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
            self.thumbnailLabel.alpha = 0.85
        }
        
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
