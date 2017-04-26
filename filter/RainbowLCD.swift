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
    
    var inputBlurRadius: CGFloat = 0.3
    var inputImage: CIImage?
    var inputRGBAngle: CGFloat = 0.25
    var inputRGBRadius: CGFloat = 0.5
    var inputCompBrightness:CGFloat = 0.11
    var inputCompContrast: CGFloat = 1.23
    var inputCompSaturation: CGFloat = 0
    var inputStripesAlpha: CGFloat = 0.8
    
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
                "inputStripesAlpha": [kCIAttributeIdentity: 0,
                                   kCIAttributeClass: "NSNumber",
                                   kCIAttributeDefault: 0.8,
                                   kCIAttributeDisplayName: "Stripes Alpha",
                                   kCIAttributeMin: 0,
                                   kCIAttributeMax: 1,
                                   kCIAttributeSliderMin: 0,
                                   kCIAttributeSliderMax: 1.0,
                                   kCIAttributeType: kCIAttributeTypeScalar],
                ]
        }
    }
    
    static func stripes(withSize size: CGSize, inputStripesAlpha: CGFloat) -> CGImage? {
        let pixelScale: CGFloat = size.height / 600
        let patternSize = CGSize(width:8, height:2 * pixelScale)
        let bitmapBytesPerRow = Int(patternSize.width * 4)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
        
        let context =  CGContext(data: nil, width: Int(patternSize.width), height: Int(patternSize.height), bitsPerComponent: 8, bytesPerRow: bitmapBytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
        
        context.setStrokeColor(gray: 0, alpha: 0)
        context.setFillColor(gray: 0, alpha: inputStripesAlpha)
        context.fill(CGRect(x:0, y:0, width: patternSize.width, height: patternSize.height))
        
        context.setFillColor(gray: 0, alpha: inputStripesAlpha)
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
            rgbFilter.inputAngle = inputRGBAngle * CGFloat(Double.pi * 2)
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
            let stripes = CIImage (cgImage:  RainbowLCD.stripes(withSize: extent.size, inputStripesAlpha: self.inputStripesAlpha)!)
            
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
//MARK: rainbow scan

class RainbowScan: RainbowLCD {
    
    var inputLineCenterX: CGFloat = 0
    var inputLineCenterY: CGFloat = 0
    var inputLineAngle: CGFloat = 0
    var inputLineWidth: CGFloat = 0
    var inputLineSharpness: CGFloat = 0.6
    
    override var outputImage: CIImage? {
        guard let inputImage = inputImage else {
            return nil
        }
        
        let extent = inputImage.extent
        let pixelScale:CGFloat = extent.size.width/600.0
        var output: CIImage?
        
        let lineFilter = CIFilter(name: "CILineScreen",
                                  withInputParameters: [
                                    kCIInputImageKey: inputImage,
                                    kCIInputCenterKey: CIVector(x: inputLineCenterX * extent.width, y: inputLineCenterY * extent.height),
                                    kCIInputAngleKey: inputLineAngle * CGFloat(Double.pi) * 2,
                                    kCIInputWidthKey: 1 + (inputLineWidth * 60),
                                    kCIInputSharpnessKey: inputLineSharpness
            ])
        Logger.log("lining…")
        output = lineFilter?.outputImage
        
        let rgbFilter = ChromaticAberration()
        rgbFilter.inputImage = output
        rgbFilter.inputAngle = inputRGBAngle * CGFloat(Double.pi * 2)
        rgbFilter.inputRadius = inputRGBRadius * 80 * pixelScale
        Logger.log("RGB shift…")
        output = rgbFilter.outputImage!
        
        Logger.log("Blur…")
        output = CIFilter(
            name: "CIGaussianBlur",
            withInputParameters: [kCIInputRadiusKey: inputBlurRadius * 50 * pixelScale,
                                  kCIInputImageKey: output as Any
            ])?.outputImage?.cropping(to: extent)

        Logger.log(output == nil ? "failed" : "ok")
        return output
    }

    override var attributes: [String : Any] {
        get{
            
            let addedAttribs: [String:Any] = [
                kCIAttributeFilterDisplayName: "Rainbow Scan" as AnyObject,
                
                "inputLineCenterX": [kCIAttributeIdentity: 0,
                                    kCIAttributeClass: "NSNumber",
                                    kCIAttributeDefault: 0,
                                    kCIAttributeDisplayName: "Center X",
                                    kCIAttributeMin: 0,
                                    kCIAttributeMax: 1,
                                    kCIAttributeSliderMin: 0.0,
                                    kCIAttributeSliderMax: 1.0,
                                    kCIAttributeType: kCIAttributeTypeScalar],
                
                "inputLineCenterY": [kCIAttributeIdentity: 0,
                                  kCIAttributeClass: "NSNumber",
                                  kCIAttributeDefault: 0,
                                  kCIAttributeDisplayName: "Center Y",
                                  kCIAttributeMin: 0,
                                  kCIAttributeMax: 1,
                                  kCIAttributeSliderMin: 0,
                                  kCIAttributeSliderMax: 1.0,
                                  kCIAttributeType: kCIAttributeTypeScalar],
                
                "inputLineAngle": [kCIAttributeIdentity: 0,
                                   kCIAttributeClass: "NSNumber",
                                   kCIAttributeDefault: 0,
                                   kCIAttributeDisplayName: "Line Angle",
                                   kCIAttributeMin: 0,
                                   kCIAttributeMax: 1,
                                   kCIAttributeSliderMin: 0,
                                   kCIAttributeSliderMax: 1.0,
                                   kCIAttributeType: kCIAttributeTypeScalar],
                
                "inputLineWidth": [kCIAttributeIdentity: 0,
                                        kCIAttributeClass: "NSNumber",
                                        kCIAttributeDefault: 0,
                                        kCIAttributeDisplayName: "Line Width",
                                        kCIAttributeMin: 0,
                                        kCIAttributeMax: 1,
                                        kCIAttributeSliderMin: 0,
                                        kCIAttributeSliderMax: 1,
                                        kCIAttributeType: kCIAttributeTypeScalar],
                "inputLineSharpness": [kCIAttributeIdentity: 0,
                                        kCIAttributeClass: "NSNumber",
                                        kCIAttributeDefault: 0,
                                        kCIAttributeDisplayName: "Line Sharpness",
                                        kCIAttributeMin: 0,
                                        kCIAttributeMax: 1,
                                        kCIAttributeSliderMin: 0,
                                        kCIAttributeSliderMax: 1,
                                        kCIAttributeType: kCIAttributeTypeScalar],
                
            ]
            
            var allParams = super.attributes
            for key in addedAttribs.keys {
                allParams[key] = addedAttribs[key]
            }
            
            return allParams
        }
    }
    
}

//MARK: RainbowLightLeak
class RainbowLightLeak: CIFilter {
    var inputCompositeTimes: Double = 0.0
    var inputImage: CIImage?
    let lcdFilter = RainbowLCD()
    
    fileprivate let FILTER_TRANSFORM = "CIAffineTransform"
    fileprivate let COMPOSITES = ["CIOverlayBlendMode","CIScreenBlendMode", "CIMultiplyCompositing",
                                  "CISoftLightBlendMode"]
    
    fileprivate var lcdImage: CIImage?
    
    fileprivate func ciImage(_ image: CIImage, alpha: CGFloat) -> CIImage? {
        let rgba: [CGFloat] = [0,0,0,alpha]
        
        guard let filter = CIFilter(name: "CIColorMatrix") else {
            return nil
        }
        
        filter.setDefaults()
        filter.setValue(image, forKey: kCIInputImageKey)
        let vector = CIVector(values: rgba, count: 4)
        filter.setValue(vector, forKey: "inputAVector")
        return filter.outputImage
    }
    
    
    
    override var outputImage: CIImage? {
        
        guard let inputImage = inputImage else {
            return nil
        }
        
        if self.lcdImage == nil {
            self.lcdFilter.setValue(inputImage, forKey: kCIInputImageKey)
            self.lcdImage = self.lcdFilter.outputImage
        }
        
        guard let lcdImage = self.lcdImage else {
            Logger.log("can't get lcdImage")
            return nil
        }
        
        let extent = inputImage.extent
        var resultImage: CIImage? = inputImage
        
        
        Logger.log("compositing…")
        let TIMES = Int(1 + self.inputCompositeTimes * 10)
        var compositeFilters = [String]()
        for _ in 0..<TIMES{
            compositeFilters.append(COMPOSITES[Int(arc4random_uniform(UInt32(COMPOSITES.count - 1)))])
        }
        Logger.log("composites: \(compositeFilters)")
        
        for t in 0..<TIMES {
            
            if resultImage == nil {
                break
            }
            let dx = CGFloat(1 + fRandom(min: 0.01, max: 0.25))
            let dy = CGFloat(1 + fRandom(min: 0.01, max: 0.25))
            
            var tx = CGAffineTransform(scaleX: dx, y: dy)
            tx = CGAffineTransform(translationX: -dx, y: -dy)
            
            Logger.log("transform…")
            let txLcdImage = lcdImage.applyingFilter(FILTER_TRANSFORM, withInputParameters: [kCIInputTransformKey: NSValue(cgAffineTransform: tx)]).cropping(to: extent)
            
            Logger.log("compositing \(t + 1)…")
            
            guard let alphaLCD = self.ciImage(txLcdImage, alpha: CGFloat(fRandom(min: 0.01, max: 0.5))) else {
                Logger.log("failed creating alpha lcd image.")
                return nil
            }
            
            resultImage = CIFilter(name: compositeFilters[t],
                              withInputParameters: [
                                kCIInputImageKey: alphaLCD,
                                kCIInputBackgroundImageKey: resultImage!
                ])?.outputImage
            
        }
        
        Logger.log("\(resultImage == nil ? "failed" : "ok")")
        
        return resultImage
    }
    
    override var attributes: [String : Any] {
        get{
            return [
                
                kCIAttributeFilterDisplayName: "Rainbow LightLeak" as AnyObject,
                
                "inputImage": [kCIAttributeIdentity: 0,
                               kCIAttributeClass: "CIImage",
                               kCIAttributeDisplayName: "Image",
                               kCIAttributeType: kCIAttributeTypeImage],
                
                
                "inputCompositeTimes": [kCIAttributeIdentity: 0,
                                    kCIAttributeClass: "NSNumber",
                                    kCIAttributeDefault: 0.1,
                                    kCIAttributeDisplayName: "Composite Times",
                                    kCIAttributeMin: 0,
                                    kCIAttributeMax: 1.0,
                                    kCIAttributeSliderMin: 0,
                                    kCIAttributeSliderMax: 1.0,
                                    kCIAttributeType: kCIAttributeTypeScalar],
                
            ]
        }
    }
}
