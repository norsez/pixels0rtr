//
//  Store.swift
//  Pixels0rtr
//
//  Created by norsez on 12/14/16.
//  Copyright © 2016 Bluedot. All rights reserved.
//

import UIKit
import StoreKit
import CargoBay

extension Notification.Name {
    static let onStoreDidPurchase = Notification.Name("onStoreDidPurchase")
    static let onStoreDidFailPurchase = Notification.Name("onStoreDidFailPurchase")
}


class Store: NSObject, SKPaymentTransactionObserver, SKRequestDelegate {
    
    enum PurchaseResult {
        case failed, cancelled, purchased, restored
    }
    
    fileprivate let PRODUCT_ID_PAID = "th.co.bluedot.pixels0rtr.paid"
    fileprivate var productRequest: SKProductsRequest?
    fileprivate var products: [SKProduct]?
    fileprivate var validateProductIdsCompletion: ((Bool)->Void)?
    
    
    var productPaidIsValidated = false
    var isPurchasing = false
    
    func initialize (withCompletion completion: @escaping (Bool)->Void) {
        
        if AppConfig.shared.isFreeVersion == false{
            Logger.log("Paid version. Thanks!")
            return
        }
        
        
        
        CargoBay.sharedManager().setPaymentQueueUpdatedTransactionsBlock { (queue, anyStuff) in
            
            guard let stuff = anyStuff else {
                Logger.log("not sure what anyStuff is \(anyStuff)")
                return
            }
            
            for s in stuff {
                if let tx = s as? SKPaymentTransaction {
                    self.paymentQueue(queue!, updatedTransactions: [tx])
                }
            }
        }
        
        SKPaymentQueue.default().add(self)
        
        CargoBay.sharedManager().products(withIdentifiers: Set([PRODUCT_ID_PAID]), success: { (goods, bads) in
            
            if let badIds = bads as? [String] {
                if badIds.contains(self.PRODUCT_ID_PAID) {
                    Logger.log("\(self.PRODUCT_ID_PAID) isn't good for sale now.")
                }
            }
            
            if let products = goods as? [SKProduct] {
                self.products = products
                self.productPaidIsValidated  = true
            }
            
        }) { (error) in
            Logger.log("error requesting products")
        }
    }
    

    
    func startPurchase() {
    
        if isPurchasing {
            Logger.log("Already purchasing. Ignored.")
            return
        }
        
        isPurchasing = true
        
        if self.productPaidIsValidated == false {
            Logger.log("product not validated. abort.")
        }
    
        
        guard let product = self.products?.first else {
            Logger.log("product not found. abort.")
            return
        }
        
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    var priceStringForHighDefinition: String {
        
        if self.productPaidIsValidated {
            if let p = self.products?.first {
                return self.stringPrice(ofProduct: p )!
            }
        }
        
        return "Problem. Try again later."
    }
    
    fileprivate func stringPrice(ofProduct product: SKProduct) -> String? {
        let df = NumberFormatter()
        df.formatterBehavior = .behavior10_4
        df.numberStyle = .currency
        df.locale = product.priceLocale
        return df.string(from: product.price)
    }
    
    //#MARK: payment queue delegate
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        isPurchasing = false
        
        
        for tx in transactions {
            if tx.transactionState == .failed {
                NotificationCenter.default.post(name: .onStoreDidFailPurchase, object: nil)
            }else if tx.transactionState == .purchased {
                self.makeAppPaidVersion(withTransaction: tx)
            }else if tx.transactionState == .restored {
                self.makeAppPaidVersion(withTransaction: tx)
            }else if tx.transactionState == .purchasing ||  tx.transactionState == .deferred {
                Logger.log("please wait… purchasing or deferred")
            }else {
                Logger.log("unhandled state:\(tx.transactionState) for \(tx.payment.productIdentifier)")
            }
            
            if tx.transactionState != .purchasing {
                SKPaymentQueue.default().finishTransaction(tx)
            }
        }
    }
    
    func makeAppPaidVersion (withTransaction tx: SKPaymentTransaction) {
        AppConfig.shared.isFreeVersion = false
        NotificationCenter.default.post(name: .onStoreDidPurchase, object: nil)
        Analytics.shared.logPurchaseSuccessful()
    }
    
    //#MARK: - singleton
    static let shared: Store = {
        let instance = Store()
        // setup code
        return instance
    }()

}

//#MARK: create
extension Store {
    
}
