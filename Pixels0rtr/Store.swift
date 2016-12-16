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


class Store: NSObject, SKPaymentTransactionObserver, SKRequestDelegate {
    
    enum PurchaseResult {
        case failed, cancelled, purchased, restored
    }
    
    fileprivate let PRODUCT_ID_PAID = "th.co.bluedot.pixels0rtr.paid"
    fileprivate var productRequest: SKProductsRequest?
    fileprivate var products: [SKProduct]?
    fileprivate var validateProductIdsCompletion: ((Bool)->Void)?
    fileprivate var purchaseCompletion:((PurchaseResult)->Bool)? //executer returns true if transaction is ready to be finished.
    
    var productPaidIsValidated = false
    var isPurchasing = false
    
    func initialize (withCompletion completion: @escaping (Bool)->Void) {
        
        if AppConfig.shared.isFreeVersion == false{
            Logger.log("Paid version. Thanks!")
            return
        }
        
        
        //self.validateProductIds(withCompletion: completion)
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
    

    
    func startPurchase(withCompletion completion: @escaping (PurchaseResult)->Bool) {
    
        if isPurchasing {
            Logger.log("Already purchasing. Ignored.")
            return
        }
        
        isPurchasing = true
        
        if self.productPaidIsValidated == false {
            Logger.log("product not validated. abort.")
            let _ = completion(.failed)
        }
    
        self.purchaseCompletion = completion
        guard let product = self.products?.first else {
            Logger.log("product not found. abort.")
            let _ = completion(.failed)
            return
        }
        
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
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
        
        if AppConfig.shared.isFreeVersion == false {
            return
        }
        
        guard let pc = self.purchaseCompletion else {
            Logger.log("no completion block for purchase waiting")
            return
        }
        
        for tx in transactions {
            if tx.transactionState == .failed {
                let _ = pc(.failed)
            }else if tx.transactionState == .purchasing {
                if pc(.purchased) {
                    self.makeAppPaidVersion(withTransaction: tx)
                    SKPaymentQueue.default().finishTransaction(tx)
                }
            }else if tx.transactionState == .restored {
                if pc(.restored) {
                    self.makeAppPaidVersion(withTransaction: tx)
                    SKPaymentQueue.default().finishTransaction(tx)
                }
            }else {
                Logger.log("unhandled state:\(tx.transactionState) for \(tx.payment.productIdentifier)")
            }
            
        }
    }
    
    func makeAppPaidVersion (withTransaction tx: SKPaymentTransaction) {
        AppConfig.shared.isFreeVersion = false
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
