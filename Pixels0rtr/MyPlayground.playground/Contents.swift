//: Playground - noun: a place where people can play

import UIKit
import QuartzCore
import PlaygroundSupport
import Pods_Pixels0rtr


extension UIImage {
    func image(withRotation radians: CGFloat, subRect: CGRect) -> (image:UIImage, rect: CGRect) {
        let cgImage = self.cgImage!
        let LARGEST_SIZE = CGFloat(max(self.size.width, self.size.height))
        let context = CGContext.init(data: nil, width:Int(LARGEST_SIZE), height:Int(LARGEST_SIZE), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: cgImage.colorSpace!, bitmapInfo: cgImage.bitmapInfo.rawValue)!
        
        var drawRect = CGRect.zero
        drawRect.size = self.size
        let drawOrigin = CGPoint(x: (LARGEST_SIZE - self.size.width) * 0.5,y: (LARGEST_SIZE - self.size.height) * 0.5)
        drawRect.origin = drawOrigin
        drawRect = drawRect.integral
        var tf = CGAffineTransform.identity
        tf = tf.translatedBy(x: LARGEST_SIZE * 0.5, y: LARGEST_SIZE * 0.5)
        tf = tf.rotated(by: CGFloat(radians))
        tf = tf.translatedBy(x: LARGEST_SIZE * -0.5, y: LARGEST_SIZE * -0.5)
        context.concatenate(tf)
        context.draw(cgImage, in: drawRect)
        var rotatedImage = context.makeImage()!
        drawRect = drawRect.applying(tf)
        rotatedImage = rotatedImage.cropping(to: drawRect)!
        let resultImage = UIImage(cgImage: rotatedImage)
        
        
        let outputRect = subRect.applying(tf)
        
        
        
        return (image:resultImage, rect:outputRect)
    }
}




func testImage() -> UIImage {
    let path = Bundle.main.path(forResource: "1", ofType: "jpg")!
    var image = UIImage(contentsOfFile: path)!
    return image
}

func test2 () {
let view = UIView(frame: CGRect(x:0, y:0, width: 800, height: 800))
let imageView = UIImageView(frame: view.bounds)
imageView.autoresizingMask = [.flexibleRightMargin, .flexibleBottomMargin]
imageView.contentMode = .topLeft

view.addSubview(imageView)

let loupeRect = CGRect(x: 0, y: 0, width: 57, height: 145)
let loupe = UIView(frame: loupeRect)
loupe.layer.borderColor = UIColor.green.cgColor
loupe.layer.borderWidth = 1


let path = Bundle.main.path(forResource: "2", ofType: "jpg")!
var image = UIImage(contentsOfFile: path)!
var output = image.image(withRotation: CGFloat( M_PI_2), subRect: loupeRect)
image = output.image.image(withRotation: CGFloat(M_PI_2), subRect: loupeRect).image
loupe.frame = output.rect
print(output.rect)

imageView.image = image
view.addSubview(loupe)
}

func recompressedImage(image: UIImage, compressionRate: CGFloat, times: Int) -> UIImage? {
    
    var currentImage = image
    
    for _ in 0..<times {
        if let data = UIImageJPEGRepresentation(currentImage, compressionRate),
            let img =  UIImage(data: data){
            currentImage = img
        }else {
            return nil
        }
    }
    return currentImage
    
}

func cgContext(withImage image:UIImage) -> CGContext? {
    guard let cgi = image.cgImage else {
        return nil
    }
    
    guard let context = CGContext(data: nil, width: cgi.width, height: cgi.height, bitsPerComponent: cgi.bitsPerComponent, bytesPerRow: cgi.bytesPerRow, space: cgi.colorSpace!, bitmapInfo: cgi.bitmapInfo.rawValue) else {
        return nil
    }
    return context
}

func longExposure(image: UIImage, times: Int) -> UIImage? {
    
    guard let cgi = image.cgImage else {
        return nil
    }
    
    let context = cgContext(withImage: image)!
    context.setFillColor(UIColor.black.cgColor)
    context.fill(CGRect(x:0, y:0, width: image.size.width, height: image.size.height))
    
    let ALPHA:CGFloat = 0.1
    context.setAlpha(ALPHA)
    
    let originalRect = CGRect(x:0, y:0, width: image.size.width, height: image.size.height)
    var rects = [CGRect]()
    for _ in 0..<64 {
        var r = originalRect
        let xMinus = Double(arc4random() % 100) > 0.5
        let yMinus = Double(arc4random() % 100) > 0.5
        let rX = Double(arc4random() % 100) * 0.01 * 15
        let rY = Double(arc4random() % 100) * 0.01 * 15
        r.origin = CGPoint(x: xMinus ? -rX : rX, y: yMinus ? -rY : rY )
        rects.append(r)
    }
    
    for _ in 0..<times {
        let rect = rects [Int(arc4random() % UInt32(rects.count))]
        let rand:Double = (Double(arc4random() % 100) * 0.01)
        let mode:CGBlendMode = rand > 0.2 ? .screen : .overlay
        context.setBlendMode(mode)
        context.draw(cgi, in: rect)
    }
    let cgiOutput = context.makeImage()!
    return UIImage(cgImage: cgiOutput)
}
let c1 = UIColor(hue: 0.34, saturation: 1, brightness: 1, alpha: 1)
let c2 = UIColor(hue: 0.34, saturation: 1, brightness: 0.3, alpha: 1)






