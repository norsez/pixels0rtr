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
    @IBOutlet var bullet1: UILabel!
    @IBOutlet var bullet2: UILabel!
    @IBOutlet var unlockButton: UIButton!
    @IBOutlet var backgroundImageView: UIImageView!
    var image: UIImage?
    var imageView: UIImageView?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.delegate = self
        
        if let di = UIImage.loadJPEG(with: "defaultImage") {
            self.backgroundImageView.image = di
        }
        
        if let img = image {
            
            self.imageView = UIImageView(image: img)
            self.imageView?.layer.masksToBounds = true
            self.imageView?.layer.cornerRadius = 5
            self.imageView?.clipsToBounds = true
            
            self.scrollView.layer.cornerRadius = 8
            self.scrollView.addSubview(self.imageView!)
            let zoomFactor = (self.scrollView?.bounds.size.width)!/(image?.size.width)!
            self.scrollView.minimumZoomScale = zoomFactor
            self.scrollView.maximumZoomScale = 4
            self.scrollView.setZoomScale(zoomFactor, animated: false)
            self.scrollView.contentSize = img.size
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
//        let views = [self.scrollView, self.titleText, self.bullet1, self.bullet2, self.unlockButton]
//        let interval: [Double] = [1, 1.2, 1.5, 2, 2.5]
//        
//        for v in views {
//            v?.alpha = 0
//        }
//        
//        for i in 0..<views.count {
//            let v = views[i]
//            UIView.animate(withDuration: interval[i], animations: { 
//                v?.alpha = 1
//            })
//        }
        
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didPressCancel(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
