//
//  ImageFilterViewController.swift
//  Pixels0rtr
//
//  Created by norsez on 3/25/17.
//  Copyright © 2017 Bluedot. All rights reserved.
//

import UIKit
import Photos


enum SelectedImageFilter: Int {
    case RGBShift, RainbowLightleak
}

class ImageFilterViewController: UIViewController {

    var inputImage: UIImage?
    var previewImage: UIImage?
    var filter: CIFilter?
    var controlKey: String?
    var controlKeys = [String]()
    
    var selectedFilter: SelectedImageFilter = .RGBShift
    
    @IBOutlet var controlSlider: UISlider!
    @IBOutlet var controlLabel: UILabel!
    @IBOutlet var controlsButton: UIButton!
    @IBOutlet var previewImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.previewImage = inputImage?.resizeToFit(size: CGSize(width: 600, height: 600))
        self.previewImageView.image = previewImage
        
        buildControls()
        
        guard let image = self.previewImage else {
                return
        }
        if let preview = self.applyFilter(withImage: image) {
            self.previewImageView.image = preview
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.buildControls()
    }

    @IBAction func didPressControlsButton(_ sender: Any) {
        let ctrl = UIAlertController(title: "select control", message: nil, preferredStyle: .actionSheet)
        for k in self.controlKeys {
            if let props = self.filter?.attributes[k] as? [String:Any] {
                let action = UIAlertAction(title: props[kCIAttributeDisplayName] as? String, style: .default, handler: { (action) in
                    self.configureSlider(withKey: k)
                })
                ctrl.addAction(action)
            }
            
        }
        self.present(ctrl, animated: true, completion: nil)
    }
    
    func buildControls() {
        
        switch self.selectedFilter  {
        case .RGBShift:
            self.filter = RainbowLCD()
        case .RainbowLightleak:
            self.filter = RainbowLightLeak()
        }
        
        
        
        guard let f = self.filter else {
            fatalError("no filter")
        }
        
        self.controlKeys = f.attributes.flatMap({ (pair) -> String? in
            if pair.key == kCIInputImageKey {
                return nil
            }
            
            if pair.key.contains("input") {
                return pair.key
            }
            
            return nil
        }).sorted(by: { (s1, s2) -> Bool in
            return s1 > s2
        })
        
        if let firstKey = self.controlKeys.first {
            self.configureSlider(withKey: firstKey)
        }
    }
    
    func configureSlider(withKey key: String) {
        guard let f = self.filter else {
            fatalError("no filter")
        }
        
        if let props = f.attributes[key] as? [String:Any] {
            self.controlKey = key
            
            if props[kCIAttributeType] as? String != kCIAttributeTypeScalar {
                return
            }
            
            if props[kCIAttributeClass] as? String != "NSNumber" {
                return
            }
            
            self.controlLabel.text = props [kCIAttributeDisplayName] as? String
            self.controlSlider.value = (props [kCIAttributeDefault] as! NSNumber).floatValue
            self.controlSlider.minimumValue = (props [kCIAttributeMin] as! NSNumber).floatValue
            self.controlSlider.maximumValue = (props [kCIAttributeMax] as! NSNumber).floatValue
        }
        
    }
    
    @IBAction func didMoveSlider(_ sender: Any) {
        
        guard let f = self.filter else {
            return
        }
        
        guard let image = self.previewImage,
            let cgImage = image.cgImage else {
            return
        }
        
        
        let ciImage = CIImage(cgImage: cgImage)
        
        if let key = self.controlKey {
            f.setValue(self.controlSlider.value, forKey: key)
            f.setValue(ciImage, forKey: "inputImage")
            
            Logger.log("\(key): \(self.controlSlider.value)")
            
            if let output = self.applyFilter(withImage: image) {
                
                self.previewImageView.image = output
                
            }
        }
        
    }
    
    @IBAction func didPressSave(_ sender: Any) {
        guard let inputImage = self.inputImage else {
            return
        }
        
        if let output = self.applyFilter(withImage: inputImage) {
            PHPhotoLibrary.shared().savePhoto(image: output, albumName: "LCD", completion: { (asset) in
                Logger.log("\(asset.debugDescription)")
            })
        }
    }
    
    func applyFilter(withImage image: UIImage) -> UIImage? {
        
        guard let cgImage = image.cgImage else {
                return nil
        }
        
        let ciImage = CIImage(cgImage: cgImage)
        self.filter?.setValue(ciImage, forKey: "inputImage")
        
        if let output = self.filter?.outputImage {
            if let cgImage = convertCIImageToCGImage(inputImage: output) {
                let image = UIImage(cgImage: cgImage)
                return image
            }
        }
        
        return nil
    }
}
