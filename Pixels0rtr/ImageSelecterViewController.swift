//
//  ImageSelecterViewController.swift
//  Pixels0rtr
//
//  Created by Norsez Orankijanan on 12/2/2559 BE.
//  Copyright © 2559 Bluedot. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices
class ImageSelecterViewController: UIImagePickerController, UIImagePickerControllerDelegate {

    
    var didPickImage: ((UIImage?)->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        if let b = self.didPickImage {
            b(nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage,
            let b = self.didPickImage {
            b(pickedImage)
        }
    }
    
    

}
