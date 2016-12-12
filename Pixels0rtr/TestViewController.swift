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
        
        self.freePaidSegmentedControl.selectedSegmentIndex = AppConfig.shared.isFreeVersion ? 0 : 1
        
        
//
//        guard let image = UIImage.loadJPEG(with: "defaultImage") else {
//            print("cant' find default image")
//            return
//        }
//        
//        guard let image600 = image.resize(byMaxPixels: 600) else {
//            print("can't get 600p")
//            return
//        }
//        
//        let sorter = SorterBrightness()
//        let pattern = PatternClassic()
//        let sp = SortParam(motionAmount: 0, sortAmount: 0.5, sorter: sorter, pattern: pattern)
//        pattern.initialize(withWidth: 600, height: 600, sortParam: sp)
//        
//        
//        
//        
//        guard let imageResult = PixelSorting.sorted(image: image600, sortParam: sp, progress: {p in print(p)}) else {
//            print("can't get image result ")
//            return
//        }
//        
//        guard let enlargedImage = imageResult.resize(image.size) else {
//            print("can't enlarge")
//            return
//        }
//        
//        self.imageView.image = enlargedImage
//        self.scrollView.contentSize = enlargedImage.size
//        self.scrollView.minimumZoomScale = 1
//        self.scrollView.maximumZoomScale = 5
//        self.scrollView.setZoomScale(1, animated: false)
//        
        
    }
    
    @IBAction func didChangeFreePaid(_ sender: Any) {
        
        AppConfig.shared.isFreeVersion = self.freePaidSegmentedControl.selectedSegmentIndex == 0
        
    }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}
