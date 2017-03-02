//: Playground - noun: a place where people can play

import UIKit
import QuartzCore
import PlaygroundSupport
import Pods_Pixels0rtr

func rand() -> CGFloat {
    return CGFloat(arc4random_uniform(255))/255
}
let v = UIView(frame: CGRect(x: 0, y: 0, width: 250, height: 250))
    

let color = UIColor(hue: rand() * 25 / 25, saturation: 0.5 + rand() * 0.5, brightness: 0.9, alpha: 1)






