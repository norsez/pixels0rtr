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


let path = Bundle.main.path(forResource: "1", ofType: "jpg")!
var image = UIImage(contentsOfFile: path)!
var output = image.image(withRotation: CGFloat( M_PI_2), subRect: loupeRect)
image = output.image.image(withRotation: CGFloat(M_PI_2), subRect: loupeRect).image
loupe.frame = output.rect
print(output.rect)

imageView.image = image
view.addSubview(loupe)


print("ok")
}


let image = testImage ()
let ti = image.cgImage!
let ctx = CGContext.init(data: nil, width: 150, height: 200, bitsPerComponent: ti.bitsPerComponent, bytesPerRow: ti.bytesPerRow, space: ti.colorSpace!, bitmapInfo: ti.bitmapInfo.rawValue)
var drawRect = CGRect(x: 0, y: 0, width: 150, height: 200)
var tf = CGAffineTransform.identity
//tf = tf.translatedBy(x: 0, y: 350)
//tf = tf.scaledBy(x: 1, y: -1)
//ctx?.concatenate(tf)

ctx?.draw(ti, in: drawRect)
ctx?.setFillColor(UIColor.green.cgColor)
ctx?.setStrokeColor(UIColor.green.cgColor)
ctx?.setLineWidth(2)
var r1 = CGRect(x: 10, y: 10, width: 35, height: 70)
tf = tf.translatedBy(x: 0, y: 200)
tf = tf.scaledBy(x: 1, y: -1)
r1 = r1.applying(tf)
ctx?.addRect(r1)
ctx?.stroke(r1, width: 1)
let b = (ctx?.makeImage())!
let output = UIImage(cgImage: b)
