//
//  SubscriptionManager.swift
//  Prankster
//
//  Created by Arpit iOS Dev. on 09/12/24.
//

import UIKit
import StoreKit
import Alamofire

class SubscriptionManager: NSObject {
    static let shared = SubscriptionManager()
    private var products: [SKProduct] = []
    var onPurchaseFailure: (() -> Void)?
    var onPurchaseSuccess: (() -> Void)?
    var onRestoreNotPurchase: (() -> Void)?
    
    private let weeklySubscriptionID = "com.prank.memes.week"
    private let monthlySubscriptionID = "com.prank.memes.month"
    private let yearlySubscriptionID = "com.prank.memes.year"
    
    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }
    
    func fetchAvailableProducts() {
        let productIDs: Set<String> = [
            weeklySubscriptionID,
            monthlySubscriptionID,
            yearlySubscriptionID
        ]
        let request = SKProductsRequest(productIdentifiers: productIDs)
        request.delegate = self
        request.start()
    }
    
    func purchaseWeeklySubscription() {
        purchaseSubscription(with: weeklySubscriptionID)
    }
    
    func purchaseMonthlySubscription() {
        purchaseSubscription(with: monthlySubscriptionID)
    }
    
    func purchaseYearlySubscription() {
        purchaseSubscription(with: yearlySubscriptionID)
    }
    
    private func purchaseSubscription(with productID: String) {
        guard let product = products.first(where: { $0.productIdentifier == productID }) else {
            print("Subscription Product Available Nathi: \(productID)")
            return
        }
        
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func isSubscriptionActive() -> Bool {
        return UserDefaults.standard.bool(forKey: "isSubscriptionActive")
    }
    
    func getWeeklyProduct() -> SKProduct? {
        return products.first(where: { $0.productIdentifier == weeklySubscriptionID })
    }
    
    func getMonthlyProduct() -> SKProduct? {
        return products.first(where: { $0.productIdentifier == monthlySubscriptionID })
    }
    
    func getYearlyProduct() -> SKProduct? {
        return products.first(where: { $0.productIdentifier == yearlySubscriptionID })
    }
}

// MARK: - SKProductsRequestDelegate
extension SubscriptionManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.products = response.products
        
        for product in products {
            print("Available Product: \(product.localizedTitle)")
            print("Price: \(product.price)")
        }
    }
}

// MARK: - SKPaymentTransactionObserver
extension SubscriptionManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                handleSuccessfulPurchase(transaction)
                onPurchaseSuccess?()
                SKPaymentQueue.default().finishTransaction(transaction)
                
            case .failed:
                print("Purchase Failed: \(transaction.error?.localizedDescription ?? "")")
                onPurchaseFailure?()
                SKPaymentQueue.default().finishTransaction(transaction)
                
            case .restored:
                handleRestored(transaction)
                onPurchaseSuccess?()
                SKPaymentQueue.default().finishTransaction(transaction)
                
            case .deferred, .purchasing:
                break
                
            @unknown default:
                break
            }
        }
    }
    
    private func handleSuccessfulPurchase(_ transaction: SKPaymentTransaction) {
        let calendar = Calendar.current
        var expirationDate: Date?
        
        switch transaction.payment.productIdentifier {
        case weeklySubscriptionID:
            expirationDate = calendar.date(byAdding: .weekOfYear, value: 1, to: Date())
        case monthlySubscriptionID:
            expirationDate = calendar.date(byAdding: .month, value: 1, to: Date())
        case yearlySubscriptionID:
            expirationDate = calendar.date(byAdding: .year, value: 1, to: Date())
        default:
            break
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("PremiumContentUnlocked"), object: nil)
        
        if let expirationDate = expirationDate {
            PremiumManager.shared.setSubscription(expirationDate: expirationDate)
        }
        
        if let receiptURL = Bundle.main.appStoreReceiptURL,
           let receiptData = try? Data(contentsOf: receiptURL) {
            let receiptString = receiptData.base64EncodedString()
        }
    }
    
    private func handleRestored(_ transaction: SKPaymentTransaction) {
        let calendar = Calendar.current
        var expirationDate: Date?
        
        switch transaction.payment.productIdentifier {
        case weeklySubscriptionID:
            expirationDate = calendar.date(byAdding: .weekOfYear, value: 1, to: Date())
        case monthlySubscriptionID:
            expirationDate = calendar.date(byAdding: .month, value: 1, to: Date())
        case yearlySubscriptionID:
            expirationDate = calendar.date(byAdding: .year, value: 1, to: Date())
        default:
            break
        }
        
        PremiumManager.shared.setSubscription(expirationDate: expirationDate!)
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        if queue.transactions.isEmpty {
            onRestoreNotPurchase?()
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        onPurchaseFailure?()
    }
}
