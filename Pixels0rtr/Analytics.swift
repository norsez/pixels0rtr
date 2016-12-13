//
//  Analytics.swift
//  Pixels0rtr
//
//  Created by norsez on 12/11/16.
//  Copyright © 2016 Bluedot. All rights reserved.
//

import UIKit
import FBSDKCoreKit
class Analytics: NSObject {
    let FacebookAppId = "1676455842685204"
    
    func logSort(withSortParam sp: SortParam) {
        FBSDKAppEvents.logEvent("Sort Action",
                                parameters:
            ["pattern": sp.pattern.name,
             "sorter": sp.sorter.name,
             "sortAmount": "\(sp.sortAmount * 100)",
             "roughnessAmount": "\(sp.roughnessAmount * 100)",
             "size": AppConfig.shared.maxPixels.description
             ])
    }
    
    func logSelectImage(withActualSize size:CGSize) {
        FBSDKAppEvents.logEvent("Select Image", parameters:
            ["width": Int(size.width),
             "height": Int(size.height)
            ]
        )
    }
    
    
    
    //#MARK: - singleton
    static let shared: Analytics = {
        let instance = Analytics()
        // setup code
        return instance
    }()

}
