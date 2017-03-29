//
//  RainbowLCD.swift
//  Pixels0rtr
//
//  Created by norsez on 3/26/17.
//  Copyright © 2017 Bluedot. All rights reserved.
//

import UIKit
import CoreImage
import CoreGraphics

func convertCIImageToCGImage(inputImage: CIImage) -> CGImage? {
    let context = CIContext(options: nil)
    return context.createCGImage(inputImage, from: inputImage.extent)
}

class RainbowLCD: CIFilter {
    
    var inputBlurRadius: CGFloat = 0.06
    var inputImage: CIImage?
    var inputRGBAngle: CGFloat = 0.25
    var inputRGBRadius: CGFloat = 0.579
    var inputCompBrightness:CGFloat = 0.11
    var inputCompContrast: CGFloat = 1.23
    var inputCompSaturation: CGFloat = 0
    
    override var attributes: [String : Any] {
        get{
            return [
                
                kCIAttributeFilterDisplayName: "RainbowLCD" as AnyObject,
                
                "inputImage": [kCIAttributeIdentity: 0,
                               kCIAttributeClass: "CIImage",
                               kCIAttributeDisplayName: "Image",
                               kCIAttributeType: kCIAttributeTypeImage],
                
                
                "inputBlurRadius": [kCIAttributeIdentity: 0,
                                        kCIAttributeClass: "NSNumber",
                                        kCIAttributeDefault: 0.2,
                                        kCIAttributeDisplayName: "Blur Radius",
                                        kCIAttributeMin: 0,
                                        kCIAttributeMax: 1,
                                        kCIAttributeSliderMin: 0.0,
                                        kCIAttributeSliderMax: 1.0,
                                        kCIAttributeType: kCIAttributeTypeScalar],
                "inputRGBAngle": [kCIAttributeIdentity: 0,
                               kCIAttributeClass: "NSNumber",
                               kCIAttributeDefault: 0.25,
                               kCIAttributeDisplayName: "RGB Angle",
                               kCIAttributeMin: 0,
                               kCIAttributeMax: 1,
                               kCIAttributeSliderMin: 0,
                               kCIAttributeSliderMax: 1.0,
                               kCIAttributeType: kCIAttributeTypeScalar],
                
                "inputRGBRadius": [kCIAttributeIdentity: 0,
                                kCIAttributeClass: "NSNumber",
                                kCIAttributeDefault: -0.35,
                                kCIAttributeDisplayName: "RGB Radius",
                                kCIAttributeMin: -1,
                                kCIAttributeMax: 1,
                                kCIAttributeSliderMin: -1.0,
                                kCIAttributeSliderMax: 1.0,
                                kCIAttributeType: kCIAttributeTypeScalar],
                
                "inputCompSaturation": [kCIAttributeIdentity: 0,
                                   kCIAttributeClass: "NSNumber",
                                   kCIAttributeDefault: 0,
                                   kCIAttributeDisplayName: "Comp Saturation",
                                   kCIAttributeMin: 0,
                                   kCIAttributeMax: 2,
                                   kCIAttributeSliderMin: 0,
                                   kCIAttributeSliderMax: 2.0,
                                   kCIAttributeType: kCIAttributeTypeScalar],
                "inputCompBrightness": [kCIAttributeIdentity: 0,
                                        kCIAttributeClass: "NSNumber",
                                        kCIAttributeDefault: 0,
                                        kCIAttributeDisplayName: "Comp Brightness",
                                        kCIAttributeMin: -1,
                                        kCIAttributeMax: 1,
                                        kCIAttributeSliderMin: -1,
                                        kCIAttributeSliderMax: 1,
                                        kCIAttributeType: kCIAttributeTypeScalar],
                
                "inputCompContrast": [kCIAttributeIdentity: 0,
                                        kCIAttributeClass: "NSNumber",
                                        kCIAttributeDefault: 1,
                                        kCIAttributeDisplayName: "Comp Contrast",
                                        kCIAttributeMin: 0,
                                        kCIAttributeMax: 2,
                                        kCIAttributeSliderMin: 0,
                                        kCIAttributeSliderMax: 2.0,
                                        kCIAttributeType: kCIAttributeTypeScalar],
                ]
        }
    }
    
    static func stripes(withSize size: CGSize) -> CGImage? {
        let pixelScale: CGFloat = size.height / 600
        let patternSize = CGSize(width:8, height:2 * pixelScale)
        let bitmapBytesPerRow = Int(patternSize.width * 4)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
        
        let context =  CGContext(data: nil, width: Int(patternSize.width), height: Int(patternSize.height), bitsPerComponent: 8, bytesPerRow: bitmapBytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
        
        context.setStrokeColor(gray: 0, alpha: 0)
        context.setFillColor(gray: 0, alpha: 0.8)
        context.fill(CGRect(x:0, y:0, width: patternSize.width, height: patternSize.height))
        
        context.setFillColor(gray: 0, alpha: 0.8)
        //context.setStrokeColor(gray: 0, alpha: 1)
        context.stroke(CGRect(x:0, y:0, width: patternSize.width, height: patternSize.height * 0.5))
        
        let patternImage = context.makeImage()!
        
        let outputContext =  CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: Int(size.width * 4), space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
        
        for x in stride(from: 0, to: size.width, by: patternSize.width)  {
            for y in stride(from: 0, to: size.height, by: patternSize.height * 2) {
                let area = CGRect(x: x, y: y, width: patternSize.width, height: patternSize.height)
                outputContext.draw(patternImage, in: area)
            }
        }
        return outputContext.makeImage()
    }
    
    override var outputImage: CIImage? {
        get {
            
            guard let inputImage = inputImage else {
                return nil
            }
            
            let extent = inputImage.extent
            let pixelScale:CGFloat = extent.size.width/600.0
            var output: CIImage?
            
            Logger.log("desaturate…")
            output = CIFilter(name: "CIColorControls",
                                      withInputParameters:
                [kCIInputSaturationKey: inputCompSaturation,
                 kCIInputContrastKey: inputCompContrast,
                 kCIInputBrightnessKey: inputCompBrightness,
                    kCIInputImageKey: inputImage
                ])?.outputImage
            
            let rgbFilter = ChromaticAberration()
            rgbFilter.inputImage = output
            rgbFilter.inputAngle = inputRGBAngle * CGFloat(M_PI * 2)
            rgbFilter.inputRadius = inputRGBRadius * 80 * pixelScale
            Logger.log("RGB shift…")
            output = rgbFilter.outputImage!
            
            
            Logger.log("Blur…")
            output = CIFilter(
                name: "CIGaussianBlur",
                withInputParameters: [kCIInputRadiusKey: inputBlurRadius * 50 * pixelScale,
                                      kCIInputImageKey: output as Any
                ])?.outputImage?.cropping(to: extent)
            
            Logger.log("create stripes…")
            let stripes = CIImage (cgImage:  RainbowLCD.stripes(withSize: extent.size)!)
            
            Logger.log("compositing…")
            output = CIFilter(name: "CIOverlayBlendMode",
                              withInputParameters: [
                                kCIInputImageKey: stripes,
                                kCIInputBackgroundImageKey: output!
                ])?.outputImage
            Logger.log(output == nil ? "failed" : "ok")
            return output
        }
    }
}
