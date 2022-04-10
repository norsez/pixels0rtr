//
//  Analytics.swift
//  Pixels0rtr
//
//  Created by norsez on 12/11/16.
//  Copyright © 2016 Bluedot. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import Firebase

class Analytics: NSObject {
    let FacebookAppId = "1676455842685204"
    
    
    func logSort(withSortParam sp: SortParam) {
        
        
        let params = ["pattern": sp.pattern.name,
                     "sorter": sp.sorter.name,
                     "sortAmount": "\(sp.sortAmount * 100)",
            "roughnessAmount": "\(sp.roughnessAmount * 100)"
        ]
        
        FBSDKAppEvents.logEvent("Sort Action",
                                parameters:params
            )
        Firebase.Analytics.logEvent("sort_action", parameters: params)
    }
    
    func logSelectImage(withActualSize size:CGSize) {
        
        
        FBSDKAppEvents.logEvent("Select Image", parameters:
            ["width": Int(size.width),
             "height": Int(size.height)
            ]
        )
        
        Firebase.Analytics.logEvent("select_image", parameters: ["width": Int(size.width),
                                                                 "height": Int(size.height)])
    }
    
    func logPurchaseSuccessful() {
        Firebase.Analytics.logEvent(AnalyticsEventEcommercePurchase, parameters:[:])
    }
    
    func logScreen(_ screenName: String) {
        
        FBSDKAppEvents.logEvent("screen", parameters: ["name": screenName])
        Firebase.Analytics.setScreenName(screenName, screenClass: nil)
    }
    
    func logButton(_ buttonName: String) {
        
        FBSDKAppEvents.logEvent("button", parameters: ["name": buttonName])
        Firebase.Analytics.logEvent("button", parameters: ["name": buttonName])
    }
    
    func initialize() {
        FirebaseApp.configure()
        Firebase.Analytics.setUserProperty(AppConfig.shared.isFreeVersion ? "free" : "paid", forName: "paid")
        #if DEBUG
            Firebase.Analytics.setUserProperty("debug", forName: "debug")
        #else
            Firebase.Analytics.setUserProperty("production", forName: "debug")
        #endif
        
        
        
    }
    
    //#MARK: - singleton
    static let shared: Analytics = {
        let instance = Analytics()
        return instance
    }()

}
