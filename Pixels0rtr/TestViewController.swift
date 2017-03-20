//
//  TestViewController.swift
//  Pixels0rtr
//
//  Created by Norsez Orankijanan on 12/6/2559 BE.
//  Copyright © 2559 Bluedot. All rights reserved.
//

import UIKit
import C4
import AssetsLibrary
class TestViewController: CanvasController, UIScrollViewDelegate {

    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var imageView: UIImageView!
    
    var toast: ToastViewController?
    
    @IBOutlet var freePaidSegmentedControl: UISegmentedControl!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.toast = self.storyboard?.instantiateViewController(withIdentifier: "ToastViewController") as? ToastViewController
        
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
            
            Batch.shared.renderFrom(point1: point1, toPoint2: point2, frames: 8, image: image, progress: { (f) in
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
}
