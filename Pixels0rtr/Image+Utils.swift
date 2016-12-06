//
//  Image+Utils.swift
//  Pixels0rtr
//
//  Created by norsez on 12/6/16.
//  Copyright © 2016 Bluedot. All rights reserved.
//

import UIKit
import CoreImage

extension UIImage {
    func blurredImage(withRadius radius: Double) -> UIImage {
        let imageToBlur = CIImage(image: self)
        let blurfilter = CIFilter(name: "CIGaussianBlur")
        blurfilter?.setValue(imageToBlur, forKey: "inputImage")
        blurfilter?.setValue(radius, forKey: "inputRadius")
        let resultImage = blurfilter?.value(forKey: "outputImage") as! CIImage
        let blurredImage = UIImage(ciImage: resultImage)
        return blurredImage
    }
}
