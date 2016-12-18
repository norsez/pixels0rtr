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
        
        

//        guard let image = UIImage.loadJPEG(with: "small") else {
//            print("cant' find default image")
//            return
//        }
//        let size = image.size.aspectFit(size: CGSize(width: 2000, height: 2000))
//        
//        guard let enlargedImage = image.resize(size) else {
//            print("can't enlarge")
//            return
//        }
//        
//        
//        self.imageView.image = enlargedImage
//        
//        self.view.addSubview(self.imageView)
        
    }
    
    @IBAction func didChangeFreePaid(_ sender: Any) {
        
        AppConfig.shared.isFreeVersion = self.freePaidSegmentedControl.selectedSegmentIndex == 0
        
    }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}
