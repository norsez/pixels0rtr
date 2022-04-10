//
//  TestViewController.swift
//  Pixels0rtr
//
//  Created by Norsez Orankijanan on 12/6/2559 BE.
//  Copyright © 2559 Bluedot. All rights reserved.
//

import UIKit
import C4
import Photos

class TestViewController: CanvasController, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    

    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var imageView: UIImageView!
    
    var toast: ToastViewController?
    var imagePicker: UIImagePickerController?
    var imagePickerMode : SelectedImageFilter = .RGBShift
    
    
    @IBOutlet var freePaidSegmentedControl: UISegmentedControl!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.toast = self.storyboard?.instantiateViewController(withIdentifier: "ToastViewController") as? ToastViewController
        
    }
    
    fileprivate func presentImagePicker(withMode mode: SelectedImageFilter) {
        
        if self.imagePicker == nil {
            self.imagePicker = UIImagePickerController()
            self.imagePicker?.delegate = self
            self.imagePicker?.allowsEditing = false
            self.imagePicker?.sourceType = .photoLibrary
        }
        self.imagePickerMode = mode
        self.present(self.imagePicker!, animated: true, completion: nil)
    }
    
    @IBAction func didCreateRGBShift(_ sender: Any) {
        
       self.presentImagePicker(withMode: .RGBShift)
    }
  
    @IBAction func didPressRainbowLeak(_ sender: Any) {
        
        self.presentImagePicker(withMode: .RainbowLightleak)
    }
    
    func createRGB(withImage img: UIImage, progress:(Float)->Void) {
        if let cgImage = img.cgImage {
            let rf = RainbowLCD()
            rf.inputImage = CIImage(cgImage: cgImage)
            
            let NUM = 12
            for n in 0..<12 {
                
                rf.inputRGBAngle =  CGFloat(n) * 2 * CGFloat(Double.pi) / CGFloat(NUM)
                rf.inputRGBRadius = 0.25
                if let ciImage = rf.outputImage{
                    let cgImage = convertCIImageToCGImage(inputImage: ciImage)
                    let output = UIImage(cgImage: cgImage!)
                    PHPhotoLibrary.shared().savePhoto(image: output, albumName: "Rainbow LCD", completion: { (asset) in
                        Logger.log("\(asset)")
                    })
                }
                
                progress(Float(n + 1)/Float(NUM))
            }
        }
    }
    
    var selectedImage: UIImage?
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let img = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            Logger.log("none selected")
            return
        }
        
        self.selectedImage = img
        
        self.dismiss(animated: true) {
            self.performSegue(withIdentifier: "imageFilter", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "imageFilter" {
            if let ctrl = segue.destination as? ImageFilterViewController {
                ctrl.inputImage = self.selectedImage
                ctrl.selectedFilter = self.imagePickerMode
            }
        }
    }
    
    
    func test1() {
        self.scrollView.backgroundColor = UIColor.black
        self.scrollView.delegate = self
        self.navigationController?.isNavigationBarHidden = false
        self.freePaidSegmentedControl.selectedSegmentIndex = AppConfig.shared.isFreeVersion ? 0 : 1
        
        
        
        guard let image = UIImage.loadJPEG(with: "defaultImage") else {
            print("cant' find default image")
            return
        }
        
        guard var cgImage = image.cgImage else {
            return
        }
        let focusRect = CGRect(x:500, y:100, width: 10, height: image.size.height)
        cgImage = cgImage.cropping(to: focusRect)!
        
        let resultImage = UIImage(cgImage: cgImage)
        var f = self.imageView.frame
        f.size = resultImage.size
        self.imageView.image = resultImage
        self.imageView.frame = f
        print (f)
    }
    
    @IBAction func didChangeFreePaid(_ sender: Any) {
        AppConfig.shared.isFreeVersion = self.freePaidSegmentedControl.selectedSegmentIndex == 0
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    
    @IBAction func didPressTestToast(_ sender: Any) {
        
        self.toast = self.storyboard?.instantiateViewController(withIdentifier: "ToastViewController") as? ToastViewController
        
        self.toast?.showToast(withText: "let's see if this works?", onViewController: self)
        
    }
    @IBAction func didPressTestBiy(_ sender: Any) {
        AppConfig.shared.isFreeVersion = true
        Store.shared.initialize { (result) in
            if result {
                Store.shared.startPurchase  () 
            }else {
                Logger.log("can't get product def")
                
            }
        }
        
    }
    
    func setProgressInMain(value: Float) {
        DispatchQueue.main.async {
            self.progressView.progress = value
        }
    }
    
    @IBAction func didPressAddToBatch(_ sender: Any) {
        
        guard let sp1 = AppConfig.shared.lastSortParam else {
            Logger.log("no current sort param")
            return
        }
        
        guard let imagePath = AppConfig.shared.lastImagePath else {
            Logger.log("no image selected")
            return
        }
        do {
            try sp1.save(withImageFilePath: imagePath)
        } catch {
            Logger.log("\(error)")
        }
    }
    
    @IBAction func didPressCreateMotion(_ sender: Any) {
        guard let sp1 = AppConfig.shared.lastSortParam else {
            Logger.log("no current sort param")
            return
        }
        
        guard let image = AppConfig.shared.lastImage else {
            Logger.log("no image selected")
            return
        }
        
        var point1 = sp1
        point1.maxPixels = .px600
        point1.blackThreshold = 1
        point1.whiteThreshold = 254
        var point2 = point1
        point2.blackThreshold = 77
        point2.whiteThreshold = 147
        var count: Int = 0
        
        //var urlsToImages = [URL]()
        
        DispatchQueue.global(qos: .userInitiated) .async {
            
            VideoRender.shared.renderFrom(point1: point1, toPoint2: point2, frames: 8, image: image, progress: { (f) in
                self.setProgressInMain(value: f)
            }, aborted: { () -> Bool in
                return false
            }, imageDone: { (image) in
                DispatchQueue.main.async {
                      UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
//                    do {
//                        var fileURL: URL? =  nil
//                        let _ = try image.save(withFileName: "_\(count)_.jpg", url: &fileURL)
//                        if let fu = fileURL {
//                            urlsToImages.append(fu)
//                        }
//                    }catch  {
//                        self.toast?.showToast(withText: "Failed", onViewController: self)
//                    }
                    count = count.advanced(by: 1)
                    self.toast?.showToast(withText: "saved \(count) images", onViewController: self)
                }
            }) {
                self.progressView.progress = 0
                //let tlb = TimeLapseBuilder(photoURLs: urlsToImages)
                
                
            }
        }
    }
    
    @IBAction func didPressCRTSim(_ sender: Any) {
        self.presentImagePicker(withMode: .CRTSim)
    }
    @IBAction func didPressBatch(_ sender: Any) {
        
        let ctrl = BatchListTableViewController(style: .plain)
        self.navigationController?.pushViewController(ctrl, animated: true)
        
        
    }
}
