//
//  TestViewController.swift
//  Pixels0rtr
//
//  Created by Norsez Orankijanan on 12/6/2559 BE.
//  Copyright © 2559 Bluedot. All rights reserved.
//

import UIKit
import C4

class TestViewController: CanvasController, UIScrollViewDelegate {

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var imageView: UIImageView!
    
    var toast: ToastViewController?
    
    @IBOutlet var freePaidSegmentedControl: UISegmentedControl!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
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
    
//    func didPressCreateSamples () {
//        
//        for pattern in ALL_SORT_PATTERNS {
//            for sorter in ALL_SORTERS {
//                let sp = SortParam(roughness: <#T##Double#>, sortAmount: <#T##Double#>, sorter: <#T##PixelSorter#>, pattern: <#T##SortPattern#>, maxPixels: <#T##AppConfig.MaxSize#>)
//            }
//        }
//        
//    }
}
