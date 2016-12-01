//
//  AppConfig.swift
//  Pixels0rtr
//
//  Created by Norsez Orankijanan on 12/1/2559 BE.
//  Copyright © 2559 Bluedot. All rights reserved.
//

import UIKit

class AppConfig: NSObject {
    
    //#MARK: - singleton
    static let shared: AppConfig = {
        let instance = AppConfig()
        // setup code
        return instance
    }()

}
