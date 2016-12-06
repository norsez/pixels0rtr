//
//  Logger.swift
//  Pixels0rtr
//
//  Created by Norsez Orankijanan on 12/6/2559 BE.
//  Copyright © 2559 Bluedot. All rights reserved.
//

import UIKit

protocol LoggerListener {
    func didReceiveLog(_ log:String)
}

class Logger: NSObject {
    
    var entries = [String]()
    fileprivate var listeners = [LoggerListener] ()
    
    func addLoggerListener(_ listener: LoggerListener) {
        self.listeners.append(listener)
    }
    
    static func log(_ log: String) {
        Logger.shared.entries.append(log)
        
        if Logger.shared.entries.count > 50 {
            let last = Logger.shared.entries.count
            let first = last - 50
            Logger.shared.entries = Array(Logger.shared.entries[first..<last])
        }
        
        for l in Logger.shared.listeners {
            l.didReceiveLog(log)
        }
    }
    
    //#MARK: - singleton
    static let shared: Logger = {
        let instance = Logger()
        // setup code
        return instance
    }()

}
