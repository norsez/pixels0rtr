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
    var image: UIImage?
    var title: String
}

class HorizontalSelectCell: UICollectionViewCell {
    
    @IBOutlet var textLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var selectedBorderView: UIView!
    var initalizedUI = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let bgView = UIView(frame: CGRect.zero)
        bgView.backgroundColor = UIColor(white: 1, alpha: 0.15)
        bgView.layer.cornerRadius = 5
        self.selectedBackgroundView = bgView
    }
}

class HorizontalSelectorCollectionViewController: UICollectionViewController {
    
    var items = [HorizontalSelectItem]()
    var didSelectItem: ((Int)->Void)?
    var selectedIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.backgroundView = nil
        self.collectionView?.backgroundColor = UIColor.clear
        self.collectionView?.allowsMultipleSelection = false
        self.collectionView?.allowsSelection = true
        self.collectionView?.showsHorizontalScrollIndicator = false
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 1
        flowLayout.minimumInteritemSpacing = 1
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        flowLayout.scrollDirection = .horizontal
        self.collectionView?.collectionViewLayout = flowLayout
        flowLayout.itemSize = CGSize(width: 120, height: 57)
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
    
}
