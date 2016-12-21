//
//  ToastViewController.swift
//  Pixels0rtr
//
//  Created by Norsez Orankijanan on 12/21/2559 BE.
//  Copyright © 2559 Bluedot. All rights reserved.
//

import UIKit

class ToastViewController: UIViewController {

    @IBOutlet weak var constraintVerticalDistance: NSLayoutConstraint!
    @IBOutlet weak var textLabel: UILabel!
    
    let INTERNAL_ANIMATION: TimeInterval = 0.25
    let INTERNAL_ANIMATION_WAIT: TimeInterval = 1
    
    func setText(_ text:String){
        self.textLabel.text = text
    }
    
    fileprivate func show(onViewController viewController: UIViewController) {
        viewController.addChildViewController(self)
        self.view.frame = viewController.view.bounds
        viewController.view.addSubview(self.view)
        self.didMove(toParentViewController: viewController)
    }
    
    fileprivate func hide(fromViewController viewController: UIViewController) {
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    func showToast(withText text: String, onViewController viewController: UIViewController) {
        
        //add to the viewController to set everything up
        self.view.alpha = 0
        self.show(onViewController: viewController)
        self.setText(text)
        self.constraintVerticalDistance.constant = -100
        self.view.layoutIfNeeded()
        self.constraintVerticalDistance.constant = 0
        UIView.animate(withDuration: INTERNAL_ANIMATION,
                       animations: {
                        self.view.alpha = 1
                        self.view.layoutIfNeeded()
        }, completion: { finished in
            self.constraintVerticalDistance.constant = 100
            UIView.animate(withDuration: self.INTERNAL_ANIMATION,
                           delay: self.INTERNAL_ANIMATION_WAIT,
                           options: [.beginFromCurrentState],
                           animations: { 
                            self.view.alpha = 0
                            self.view.layoutIfNeeded()
            }, completion: {
                finished in
                if finished {
                    self.hide(fromViewController: viewController)
                }
            })
        })
        
    }
    
}
