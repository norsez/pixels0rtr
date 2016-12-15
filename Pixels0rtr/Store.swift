//
//  Store.swift
//  Pixels0rtr
//
//  Created by norsez on 12/14/16.
//  Copyright © 2016 Bluedot. All rights reserved.
//

import UIKit
import StoreKit
class Store: NSObject {
    
    let PRODUCT_ID = "th.co.bluedot.pixels0rtr.paid"
    
    func initialize () {
        if false == AppConfig.shared.isFreeVersion {
            return
        }
        
        
    }
        //#MARK: - singleton
    static let shared: Store = {
        let instance = Store()
        // setup code
        return instance
    }()

}
