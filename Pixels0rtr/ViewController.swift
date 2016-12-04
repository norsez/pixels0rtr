//
//  ViewController.swift
//  Pixels0rtr
//
//  Created by Norsez Orankijanan on 11/30/2559 BE.
//  Copyright © 2559 Bluedot. All rights reserved.
//

import UIKit
import MobileCoreServices
import ImagePicker
import C4

class ViewController: UIViewController, ImagePickerDelegate, UIScrollViewDelegate {

    @IBOutlet var imageScrollView: UIScrollView!
    @IBOutlet weak var selectImageButton: UIBarButtonItem!
    
    @IBOutlet var progressView: UIProgressView!
    
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageScrollView.delegate = self

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    //MARK: image selector
    @IBAction func didPressSelectImage(_ sender: Any) {
        let imagePickerController = ImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.imageLimit = 1
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func display(image: UIImage) {
        self.imageView.image = image
        self.imageView.frame.size = image.size
        self.imageScrollView.contentSize = self.imageView.frame.size
        let minScale = min(self.imageScrollView.frame.size.width/image.size.width, 1);
        self.imageScrollView.minimumZoomScale = minScale
        self.imageScrollView.maximumZoomScale = 5
        
        self.imageScrollView.setZoomScale(minScale, animated: true)
        
        
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
    }
    
    
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
        dismiss(animated: true, completion: nil)
        
        if var img = images.first  {
            print("original size: \(img.size)")
            
            if true {
                img = img.resize(byMaxPixels: 600)!
            }
            
            print("image size: \(img.size)")
            
            self.display(image: img)
            let pattern = PatternClassic()
            let sorter = SorterBrightness()
            
            self.progressView.progress = 0
            DispatchQueue.global().async {
                print("init pattern…")
                let imageToSort = Image(uiimage:img)
                pattern.initialize(withWidth: Int(imageToSort.width), height: Int(imageToSort.height), amount: 0.05, motion: 0)
                
                let sortedImage = PixelSorting.sorted(image: imageToSort , pattern: pattern, sorter: sorter, progress: { p in
                    DispatchQueue.main.async {
                        self.progressView.progress = p
                    }
                })
                
                DispatchQueue.main.async {
                    self.progressView.progress = 1
                    self.display(image: sortedImage.uiimage)
                }
                
            }
            
            
            
        }
        
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        
    }
    
    
    
}

