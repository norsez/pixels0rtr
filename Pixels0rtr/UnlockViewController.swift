//
//  UnlockViewController.swift
//  Pixels0rtr
//
//  Created by norsez on 12/12/16.
//  Copyright © 2016 Bluedot. All rights reserved.
//

import UIKit

class UnlockViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var titleText: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet var bullet1: UILabel!
    @IBOutlet var bullet2: UILabel!
    @IBOutlet var unlockButton: UIButton!
    @IBOutlet var backgroundImageView: UIImageView!
    var image: UIImage?
    var imageView: UIImageView?
    
    
    @IBOutlet var orIfLabel: UILabel!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var restoreButton: UIButton!
    
    var toast: ToastViewController?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.delegate = self
        self.toast = self.storyboard?.instantiateViewController(withIdentifier: "ToastViewController") as? ToastViewController
        
        if let di = UIImage.loadJPEG(with: "defaultImage") {
            self.backgroundImageView.image = di
        }
        
        if let img = image {
            
            self.imageView = UIImageView(image: img)
            self.imageView?.layer.masksToBounds = true
            self.imageView?.layer.cornerRadius = 5
            self.imageView?.clipsToBounds = true
            //self.scrollView.backgroundColor = UIColor.red
            self.scrollView.layer.cornerRadius = 8
            self.scrollView.contentSize = img.size
            self.scrollView.addSubview(self.imageView!)
            
            let zoomFactor = (self.scrollView?.bounds.size.width)!/(image?.size.width)!
            self.scrollView.minimumZoomScale = zoomFactor
            self.scrollView.maximumZoomScale = 4
            
            let doubleTapToZoomToFit = UITapGestureRecognizer(target: self, action: #selector(zoomToFit(_:)))
            doubleTapToZoomToFit.numberOfTapsRequired = 2
            doubleTapToZoomToFit.numberOfTouchesRequired = 1
            self.scrollView.addGestureRecognizer(doubleTapToZoomToFit)
            
        }
        
        self.priceLabel.text = Store.shared.priceStringForHighDefinition
        
        NotificationCenter.default.addObserver(self, selector: #selector(storeDidPurchase), name: .onStoreDidPurchase, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(storeDidFail), name: .onStoreDidFailPurchase, object: nil)
        
        
//        #if DEBUG
//            let tap4 = UITapGestureRecognizer(target: self, action: #selector(testAnimation))
//            tap4.numberOfTapsRequired = 4
//            self.bullet2.addGestureRecognizer(tap4)
//            self.bullet2.isUserInteractionEnabled = true
//        #endif
    }
    
    @objc fileprivate func storeDidFail() {
        self.restoreButton.isEnabled = true
        self.unlockButton.isEnabled = true
    }
    
    @objc fileprivate func storeDidPurchase () {
        self.animateSuccess ()
    }
    
    @objc fileprivate func testAnimation() {
        self.animateSuccess ()
    }
    
    @objc func zoomToFit(_ gesture: UITapGestureRecognizer) {
        self.scrollView.setZoomScale(self.scrollView.minimumZoomScale, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Analytics.shared.logScreen("Unlock")
        self.scrollView.setZoomScale(self.scrollView.minimumZoomScale, animated: true)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didPressCancel(_ sender: Any) {
        Analytics.shared.logButton("cancelUnlock")
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didPressUnlock(_ sender: Any) {
        self.restoreButton.isEnabled = false
        self.unlockButton.isEnabled = false
        Analytics.shared.logButton("Unlock Purchase")
        Store.shared.startPurchase ()
        self.toast?.showToast(withText: "Contacting iTunes…", onViewController: self)
    }
    
    func animateSuccess () {
        let toFade: [UIView] = [self.restoreButton, self.orIfLabel, self.cancelButton, self.unlockButton, self.scrollView, self.titleText, self.bullet2, self.priceLabel]
        UIView.animate(withDuration: 1, animations: { 
            for v in toFade {
                v.alpha = 0
            }
            
        }) { (finished) in
            if finished {
                self.bullet2.text = "Thank you!"
                self.bullet2.textAlignment = .center
                self.bullet2.font = UIFont(name: "Silom", size: 64)
            }
            UIView.animate(withDuration: 3, animations: { 
                self.bullet2.alpha = 1
            }, completion: { (finished) in
                if finished {
                    self.presentingViewController?.dismiss(animated: true, completion: {
                        
                        self.presentingViewController?.dismiss(animated: true, completion: nil)
                    })
                }
            })
        }
    }


}
