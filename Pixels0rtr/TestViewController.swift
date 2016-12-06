//
//  TestViewController.swift
//  Pixels0rtr
//
//  Created by Norsez Orankijanan on 12/6/2559 BE.
//  Copyright © 2559 Bluedot. All rights reserved.
//

import UIKit
import C4

class TestViewController: CanvasController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.canvas.backgroundColor = black
        
        guard let image = UIImage.loadJPEG(with: "defaultImage") else {
            print("default image")
            return
        }
        
        let sp = SortingPreview()
        
        if let resizedImage = image.resize(byMaxPixels: 100),
            let output = sp.imageToSort(withImage: resizedImage) {
            let td = Image(uiimage: output)
            td.frame = Rect(0, 64, 108, 108)
            self.canvas.add(td)
        }
    }
}
