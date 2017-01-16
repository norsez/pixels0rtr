//: Playground - noun: a place where people can play

import UIKit
import QuartzCore

let path = Bundle.main.path(forResource: "1", ofType: "jpg")!
let image = UIImage(contentsOfFile: path)!
let cgImage = image.cgImage!
let LARGEST_SIZE = CGFloat(max(image.size.width, image.size.height))
let context = CGContext.init(data: nil, width:Int(LARGEST_SIZE), height:Int(LARGEST_SIZE), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: cgImage.colorSpace!, bitmapInfo: cgImage.bitmapInfo.rawValue)!

var drawRect = CGRect.zero
drawRect.size = image.size
let drawOrigin = CGPoint(x: (LARGEST_SIZE - image.size.width) * 0.5,y: (LARGEST_SIZE - image.size.height) * 0.5)
drawRect.origin = drawOrigin
var tf = CGAffineTransform.identity
tf = tf.translatedBy(x: LARGEST_SIZE * 0.5, y: LARGEST_SIZE * 0.5)
tf = tf.rotated(by: CGFloat(M_PI))
tf = tf.translatedBy(x: LARGEST_SIZE * -0.5, y: LARGEST_SIZE * -0.5)
context.concatenate(tf)
context.draw(cgImage, in: drawRect)
var rotatedImage = context.makeImage()!

drawRect = drawRect.applying(tf)

rotatedImage = rotatedImage.cropping(to: drawRect)!
var resultImage = UIImage(cgImage: rotatedImage)
