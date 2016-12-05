//
//  ViewController.swift
//  Pixels0rtr
//
//  Created by Norsez Orankijanan on 11/30/2559 BE.
//  Copyright © 2559 Bluedot. All rights reserved.
//

import UIKit
import MobileCoreServices

import C4

class ViewController: UIViewController, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

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
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    
    func display(image: UIImage) {
        self.imageView.image = image
        self.imageView.frame.size = image.size
        self.imageScrollView.contentSize = self.imageView.frame.size
        let minScale = self.imageScrollView.frame.size.width < image.size.width ? self.imageScrollView.frame.size.width/image.size.width : 1
        self.imageScrollView.minimumZoomScale = minScale
        self.imageScrollView.maximumZoomScale = 2
        self.imageScrollView.setZoomScale(minScale, animated: true)
        
        
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        dismiss(animated: true, completion: nil)
        print(info)
        guard var img = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            print("none selected")
            return
        }
        
        print("original size: \(img.size)")
        
        if true {
            img = img.resize(byMaxPixels: 600)!
        }
        
        print("image size: \(img.size)")
        
        self.display(image: img)
        
        
        self.progressView.progress = 0
        DispatchQueue.global().async {
            print("init pattern…")
            let imageToSort = Image(uiimage:img)
            
            let sortParameters = AppConfig.shared.SortParameters
            
            sortParameters.pattern.initialize(withWidth: Int(imageToSort.width), height: Int(imageToSort.height), sortParam: sortParameters)
            
            let sortedImage = PixelSorting.sorted(image: imageToSort , sortParam: sortParameters, progress: { p in
                DispatchQueue.main.async {
                    self.progressView.progress = Float(p)
                }
            })
            
            DispatchQueue.main.async {
                self.progressView.progress = 1
                self.display(image: sortedImage.uiimage)
                UIImageWriteToSavedPhotosAlbum(sortedImage.uiimage, nil, nil, nil)
            }
            
        }
    }
    
}

