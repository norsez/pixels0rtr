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
    
    @IBOutlet var freePaidSegmentedControl: UISegmentedControl!
    override func viewDidLoad() {
        super.viewDidLoad()
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
}
