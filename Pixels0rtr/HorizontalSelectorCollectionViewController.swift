//
//  HorizontalSelectorCollectionViewController.swift
//  Pixels0rtr
//
//  Created by norsez on 12/5/16.
//  Copyright © 2016 Bluedot. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

struct HorizontalSelectItem {
    var image: UIImage
    var title: String
}

class HorizontalSelectCell: UICollectionViewCell {
    
    @IBOutlet var textLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var selectedBorderView: UIView!
    var initalizedUI = false
    
//    
//    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        
//        if !self.initalizedUI {
//            self.selectedBorderView.layer.cornerRadius = 4
//            self.selectedBorderView.layer.borderColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0.8).cgColor
//            self.initalizedUI = true
//        }
//        
//        self.selectedBorderView.isHidden = !self.isHighlighted
//        self.imageView.alpha = self.isHighlighted ? 0.2 : 0.9
//    }
//    
    
}

class HorizontalSelectorCollectionViewController: UICollectionViewController {
    
    var items = [HorizontalSelectItem]()
    var didSelectItem: ((Int)->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.backgroundView = nil
        self.collectionView?.backgroundColor = UIColor.clear
        self.collectionView?.allowsMultipleSelection = false
        self.collectionView?.allowsSelection = true
    }

// MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! HorizontalSelectCell
    
        let item = self.items[indexPath.row]
        cell.imageView.image = item.image
        cell.textLabel.text = item.title
        return cell
    }

    // MARK: UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let c = self.didSelectItem {
            c(indexPath.row)
        }
        
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
