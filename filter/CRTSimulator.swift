//
//  CRTSimulator.swift
//  Pixels0rtr
//
//  Created by Norsez Orankijanan on 21/2/2561 BE.
//  Copyright © 2561 Bluedot. All rights reserved.
//

import UIKit
import QuartzCore

//MARK:
extension CGContext {
    var flippedCoordinateImage: CIImage? {
        var xForm = CGAffineTransform(translationX: 0, y: CGFloat(self.height))
        xForm = xForm.scaledBy(x: 1, y: -1)
        let extent = CGRect(x:0, y:0, width: CGFloat(self.width), height: CGFloat(self.height))
        
        guard let cgImage = self.makeImage().flatMap({ $0 }) else {
            print("can't create cgImage")
            return nil
        }
        
        let ciImage = CIImage(cgImage:cgImage)
        
        let xformFilter = CIFilter(name: "CIAffineTransform", withInputParameters:[kCIInputTransformKey: NSValue(cgAffineTransform: xForm), kCIInputImageKey:  ciImage])
        
        
        guard let ciImageOutput = xformFilter?.outputImage?.cropped(to: extent) else {
            print("can't create ciimage for output")
            return nil
        }
        return ciImageOutput
    }
}

//MARK:
class CRTSimulator {
    
    var inputImage: UIImage?
    var context: CGContext?
    var outputImage: UIImage?
    
    func run() {
        
    }
    static func createCRTSimulation(withImage image: UIImage) -> UIImage? {
        let instance = CRTSimulator()
        instance.inputImage = image
        instance.run()
        return instance.outputImage
    }
}



//MARK:
class  DotPitch {
    //var bloomRadius = 2.5
    var pixel_w: Double = 6
    var pixel_h: Double = 4
    var pixel_margin: Double = 3
    var dotColor: SortColor? =  SortColor(withRed: 255, green: 255, blue: 255, alpha: 255)
    var _brightnessCurve: Double = 1
    var _lookupBrightness = [UInt8]()
    var doNotAddBloom = false
    
    let TABLE_SIZE = 256
    
    var brightnessCurve: Double {
        set(value) {
            _brightnessCurve = value
            _lookupBrightness = [UInt8]()
            for i in 0..<self.TABLE_SIZE {
                let item = 255 * ( 1.0 - pow((1.0-(Double(i)/255.0)), _brightnessCurve))
                _lookupBrightness.append(UInt8(item))
            }
        }
        get {
            return _brightnessCurve
        }
    }
    
    
    init(pixel_w: Double, pixel_h: Double, pixel_margin: Double) {
        self.pixel_w = pixel_w
        self.pixel_h = pixel_h
        self.pixel_margin = pixel_margin
        self.brightnessCurve = 2
    }
    
    convenience init(pixelSize: Int) {
        self.init(pixel_w: Double(pixelSize),
                  pixel_h: Double(pixelSize * 3), pixel_margin: Double(pixelSize - 1))
        
    }
    
    func scaledBright(withOriginalBrightness b: Double)->UInt8 {
        return _lookupBrightness[Int(b)]
    }
    
    var pixelWidth: Int {
        return Int((self.pixel_margin * 2 ) + (self.pixel_w * 3))
    }
    
    var pixelHeight: Int {
        return Int((self.pixel_margin * 2) + self.pixel_h)
    }
    
    var _red: SortColor {
        get{
            return SortColor(withRed: UInt8(self.scaledBright(withOriginalBrightness: self.dotColor?.red ?? 0)), green: 0, blue: 0, alpha: 255)
        }
    }
    
    var _green: SortColor {
        get{
            return SortColor(withRed: 0, green: UInt8(self.scaledBright(withOriginalBrightness: self.dotColor?.green ?? 0)), blue: 0, alpha: 255)
        }
    }
    
    var _blue: SortColor {
        get{
            return SortColor(withRed: 0, green: 0, blue: UInt8(self.scaledBright(withOriginalBrightness: self.dotColor?.blue ?? 0)), alpha: 255)
        }
    }
    
    func draw(pg: CGContext) {
        assert(false, "implement this")
    }
}

class ApertureGrilleDV: DotPitch {
    var numDepths: Double = 2
    var glowFactor: Double = 4
    var glowDecay: Double = 4
    var strokeWeights = [Double]()
    
    init(pixelSize: Int) {
        super.init(pixel_w: Double(pixelSize),
                  pixel_h: Double(pixelSize * 3), pixel_margin: Double(pixelSize - 1))
        self.createTableLookup()
    }
    
    func createTableLookup() {
        self.strokeWeights = [Double]()
        for i in 0..<Int(numDepths) {
            let v = self.pixel_w * glowFactor * pow(Double(i+1)/Double(numDepths), glowDecay)
            self.strokeWeights.append(v)
        }
    }
    
    func strokeLine(pg: CGContext, color: SortColor)  {
        let l_color = SortColor(withRed: UInt8(color.red), green: UInt8(color.green), blue: UInt8(color.blue), alpha: UInt8(255.0/numDepths))
        
        for i in 0..<Int(numDepths) {
            pg.setStrokeColor(l_color.C4Color.cgColor)
            let lineWidth = CGFloat(strokeWeights[i])
            pg.setLineCap(.round)
            pg.setLineWidth(lineWidth)
            pg.move(to: CGPoint(x:self.pixel_margin,y:self.pixel_margin))
            pg.addLine(to: CGPoint(x:self.pixel_margin, y: self.pixel_h))
            pg.strokePath()
        }
    }
    
    override func draw(pg: CGContext) {
        pg.setBlendMode(.screen)
        pg.setLineCap(.round)
        pg.setFillColor(UIColor.clear.cgColor)
        self.strokeLine(pg: pg, color: self._red)
        pg.translateBy(x: CGFloat(self.pixel_w + self.pixel_margin), y: 0)
        self.strokeLine(pg: pg, color: self._green)
        pg.translateBy(x: CGFloat(self.pixel_w), y: 0)
        self.strokeLine(pg: pg, color: self._blue)
    }
}



//MARK: CRT Display
class CRTDisplay: CIFilter {
    @objc var inputImage: CIImage?
    var scaledImage: UIImage?
    
    //var displayX = 240
    //var displayY = 180
    var outputScaling = 4
    var output_x: Double = 240
    var output_y: Double = 180
    
    var inputPixelSize = 3
    var pixel_w = 3
    var pixel_h = 9
    var pixel_margin = 1
    var inputGlowFactor = 4
    var inputGlowDecay = 4
    
    var dotPitch = ApertureGrilleDV(pixelSize: 3)
    var inputBrightnessCurve = 2.0
    
    var inputMaxInputSize = 0
    
    override var attributes: [String : Any] {
        get{
            return [
                
                kCIAttributeFilterDisplayName: "CRT Simulation" as AnyObject,
                
                "inputImage": [kCIAttributeIdentity: 0,
                               kCIAttributeClass: "CIImage",
                               kCIAttributeDisplayName: "Image",
                               kCIAttributeType: kCIAttributeTypeImage],
                "inputPixelSize": [ kCIAttributeIdentity: 3,
                                kCIAttributeClass: "NSNumber",
                                kCIAttributeDefault: 3,
                                kCIAttributeDisplayName: "pixelSize",
                    kCIAttributeMin: 1,
                    kCIAttributeMax: 7,
                    kCIAttributeSliderMin: 1,
                    kCIAttributeSliderMax: 7,
                    kCIAttributeType: kCIAttributeTypeScalar
                            ],
                "inputGlowFactor": [ kCIAttributeIdentity: 0,
                                    kCIAttributeClass: "NSNumber",
                                    kCIAttributeDefault: 4,
                                    kCIAttributeDisplayName: "Glow Size",
                                    kCIAttributeMin: 0.25,
                                    kCIAttributeMax: 10,
                                    kCIAttributeSliderMin: 0.25,
                                    kCIAttributeSliderMax: 10,
                                    kCIAttributeType: kCIAttributeTypeScalar
                ],
                "inputGlowDecay": [ kCIAttributeIdentity: 0,
                                     kCIAttributeClass: "NSNumber",
                                     kCIAttributeDefault: 4,
                                     kCIAttributeDisplayName: "Glow Decay",
                                     kCIAttributeMin: 2,
                                     kCIAttributeMax: 20,
                                     kCIAttributeSliderMin: 2,
                                     kCIAttributeSliderMax: 20,
                                     kCIAttributeType: kCIAttributeTypeScalar
                ],
                "inputMaxInputSize": [ kCIAttributeIdentity: 0,
                                    kCIAttributeClass: "NSNumber",
                                    kCIAttributeDefault: 0,
                                    kCIAttributeDisplayName: "Max Input Size",
                                    kCIAttributeMin: 0,
                                    kCIAttributeMax: 6,
                                    kCIAttributeSliderMin: 0,
                                    kCIAttributeSliderMax: 6,
                                    kCIAttributeType: kCIAttributeTypeScalar
                ],
                "inputBrightnessCurve": [ kCIAttributeIdentity: 0,
                                       kCIAttributeClass: "NSNumber",
                                       kCIAttributeDefault: 0,
                                       kCIAttributeDisplayName: "Brightness Curve",
                                       kCIAttributeMin: 0.25,
                                       kCIAttributeMax: 4,
                                       kCIAttributeSliderMin: 0.25,
                                       kCIAttributeSliderMax: 4,
                                       kCIAttributeType: kCIAttributeTypeScalar
                ],
            ]
        }
    }
    
    
    func setBrightnessCurve(withValue v: Double) {
        self.dotPitch.brightnessCurve = v
    }
    
   
    override var outputImage: CIImage? {
        get {
            
            guard let inputImage = self.inputImage else {
                return nil
            }
            
            let uiimage = UIImage(ciImage: inputImage)
            let INPUT_SIZE = [24,48, 64, 120, 240, 320, 480]
            self.scaledImage = uiimage.resize(byMaxPixels: INPUT_SIZE[self.inputMaxInputSize])
            self.dotPitch = ApertureGrilleDV(pixelSize: self.inputPixelSize)
            self.dotPitch.pixel_w = Double(self.inputPixelSize)
            self.dotPitch.pixel_h = Double(self.inputPixelSize * 3)
            self.dotPitch.pixel_margin = Double(self.inputPixelSize)
            self.dotPitch.glowFactor = Double(self.inputGlowFactor)
            self.dotPitch.glowDecay = Double(self.inputGlowDecay)
            self.dotPitch.brightnessCurve = Double(self.inputBrightnessCurve)
            self.dotPitch.createTableLookup()
            
            let displayX = Int(self.scaledImage?.size.width ?? 0)
            let displayY = Int(self.scaledImage?.size.height ?? 0)
            self.output_x = Double(displayX * self.dotPitch.pixelWidth)
            self.output_y = Double(displayY * self.dotPitch.pixelHeight)
            
            let w_times = self.dotPitch.pixelWidth
            let h_times = self.dotPitch.pixelHeight
            let bitmapBytesPerRow = output_x * 4
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
            let context = CGContext(data: nil, width: Int(output_x), height: Int(output_y), bitsPerComponent: 8, bytesPerRow: Int(bitmapBytesPerRow), space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
            var max_bright: Double = 0
            if let colorArrays = self.scaledImage?.colorArrays() {
                for x in 0..<Int(self.scaledImage!.size.width) {
                    for y in 0..<Int(self.scaledImage!.size.height) {
                        let c = colorArrays[x][y]
                        self.dotPitch.dotColor = c
                        max_bright = max(max_bright, c.brightness)
                        context.saveGState()
                        context.translateBy(x: CGFloat(x * w_times), y: CGFloat( y * h_times))
                        self.dotPitch.draw(pg: context)
                        context.restoreGState()
                    }
                }
            }
            
            return context.flippedCoordinateImage
        }
    }
}

