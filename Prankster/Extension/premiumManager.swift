//
//  premiumManager.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 14/11/24.
//
//
//import Foundation
//
//class PremiumManager {
//    static let shared = PremiumManager()
//    private let defaults = UserDefaults.standard
//    private let allUnlockedKey = "allContentUnlocked"
//    
//
//    private var temporarilyUnlockedContent: Set<Int> = []
//    
//    func isContentUnlocked(itemID: Int) -> Bool {
//
//        if defaults.bool(forKey: allUnlockedKey) {
//            return true
//        }
//
//        return temporarilyUnlockedContent.contains(itemID)
//    }
//    
//    func temporarilyUnlockContent(itemID: Int) {
//        temporarilyUnlockedContent.insert(itemID)
//    }
//    
//    func unlockAllContent() {
//        defaults.set(true, forKey: allUnlockedKey)
//    }
//
//    func clearTemporaryUnlocks() {
//        temporarilyUnlockedContent.removeAll()
//    }
//}


import Foundation
import UIKit
import StoreKit
import Alamofire

class PremiumManager {
    static let shared = PremiumManager()
    private let defaults = UserDefaults.standard
    
    private let allUnlockedKey = "allContentUnlocked"
    private let weeklyUnlockedKey = "weeklyContentUnlocked"
    private let monthlyUnlockedKey = "monthlyContentUnlocked"
    private let premiumExpirationKey = "premiumExpirationDate"
    
    private var temporarilyUnlockedContent: Set<Int> = []
    
    private init() {}
    
    func isContentUnlocked(itemID: Int) -> Bool {
        if defaults.bool(forKey: allUnlockedKey) {
            return true
        }
        
        if isWeeklyPremiumActive() || isMonthlyPremiumActive() {
            return true
        }
        
        return temporarilyUnlockedContent.contains(itemID)
    }
    
    func temporarilyUnlockContent(itemID: Int) {
        temporarilyUnlockedContent.insert(itemID)
    }
    
    func unlockAllContent() {
        defaults.set(true, forKey: allUnlockedKey)
        clearTemporaryUnlocks()
    }
    
    func unlockWeeklyContent() {
        let expirationDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())
        defaults.set(true, forKey: weeklyUnlockedKey)
        defaults.set(expirationDate, forKey: premiumExpirationKey)
    }
    
    func unlockMonthlyContent() {
        let expirationDate = Calendar.current.date(byAdding: .month, value: 1, to: Date())
        defaults.set(true, forKey: monthlyUnlockedKey)
        defaults.set(expirationDate, forKey: premiumExpirationKey)
    }
    
    func isWeeklyPremiumActive() -> Bool {
        guard let expirationDate = defaults.object(forKey: premiumExpirationKey) as? Date else {
            return false
        }
        return defaults.bool(forKey: weeklyUnlockedKey) && expirationDate > Date()
    }
    
    func isMonthlyPremiumActive() -> Bool {
        guard let expirationDate = defaults.object(forKey: premiumExpirationKey) as? Date else {
            return false
        }
        return defaults.bool(forKey: monthlyUnlockedKey) && expirationDate > Date()
    }
    
    func clearTemporaryUnlocks() {
        temporarilyUnlockedContent.removeAll()
        defaults.removeObject(forKey: weeklyUnlockedKey)
        defaults.removeObject(forKey: monthlyUnlockedKey)
        defaults.removeObject(forKey: premiumExpirationKey)
    }
    
    func checkAndClearExpiredPremium() {
        guard let expirationDate = defaults.object(forKey: premiumExpirationKey) as? Date else {
            return
        }
        
        if expirationDate < Date() {
            clearTemporaryUnlocks()
        }
    }
}


//import Foundation
//import StoreKit
//
//class SubscriptionManager {
//    // Singleton instance
//    static let shared = SubscriptionManager()
//    
//    // Subscription Product Identifiers
//    enum SubscriptionType: String, CaseIterable {
//        case weekly = "com.prank.memes.week"
//        case monthly = "com.prank.memes.month"
//        case yearly = "com.prank.memes.year"
//    }
//    
//    // Products available for purchase
//    private var products: [SKProduct] = []
//    
//    // Current active subscription
//    private(set) var activeSubscription: SubscriptionType?
//    
//    private init() {
//        // Restore any existing subscription on initialization
//        restorePersistedSubscription()
//    }
//    
//    private func restorePersistedSubscription() {
//        if let savedSubscription = UserDefaults.standard.string(forKey: "ActiveSubscription"),
//           let subscriptionType = SubscriptionType(rawValue: savedSubscription) {
//            activeSubscription = subscriptionType
//        }
//    }
//    
//    // Fetch available subscription products
//    func fetchProducts(completion: @escaping (Result<[SKProduct], Error>) -> Void) {
//        let productIdentifiers = Set(SubscriptionType.allCases.map { $0.rawValue })
//        let request = SKProductsRequest(productIdentifiers: productIdentifiers)
//        
//        request.delegate = self
//        request.start()
//        
//        // Keep track of the completion handler
//        self.productsRequestCompletion = completion
//    }
//    
//    // Purchase a specific subscription
//    func purchase(subscription: SubscriptionType, completion: @escaping (Result<Bool, Error>) -> Void) {
//        guard let product = products.first(where: { $0.productIdentifier == subscription.rawValue }) else {
//            completion(.failure(SubscriptionError.productNotFound))
//            return
//        }
//        
//        let payment = SKMutablePayment()
//        payment.product = product
//        SKPaymentQueue.default().add(payment)
//        
//        // Store the completion handler
//        self.purchaseCompletion = completion
//    }
//    
//    // Restore previous purchases
//    func restorePurchases(completion: @escaping (Result<Bool, Error>) -> Void) {
//        SKPaymentQueue.default().restoreCompletedTransactions()
//        self.restoreCompletion = completion
//    }
//    
//    // Verify current subscription status
//    func checkSubscriptionStatus() -> Bool {
//        return activeSubscription != nil
//    }
//    
//    // Check if a specific subscription type is active
//    func isSubscriptionActive(_ type: SubscriptionType) -> Bool {
//        return activeSubscription == type
//    }
//}
//
//// MARK: - StoreKit Delegate Methods
//extension SubscriptionManager: SKProductsRequestDelegate, SKPaymentTransactionObserver {
//    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
//        self.products = response.products
//        self.productsRequestCompletion?(.success(response.products))
//    }
//    
//    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
//        for transaction in transactions {
//            switch transaction.transactionState {
//            case .purchased:
//                handlePurchasedTransaction(transaction)
//            case .failed:
//                handleFailedTransaction(transaction)
//            case .restored:
//                handleRestoredTransaction(transaction)
//            case .deferred, .purchasing:
//                break
//            @unknown default:
//                break
//            }
//        }
//    }
//    
//    private func handlePurchasedTransaction(_ transaction: SKPaymentTransaction) {
//        defer {
//            SKPaymentQueue.default().finishTransaction(transaction)
//        }
//        
//        guard let subscriptionType = SubscriptionType(rawValue: transaction.payment.productIdentifier) else {
//            purchaseCompletion?(.failure(SubscriptionError.invalidProductIdentifier))
//            return
//        }
//        
//        // Update local subscription status
//        activeSubscription = subscriptionType
//        
//        // Persist subscription info
//        UserDefaults.standard.set(subscriptionType.rawValue, forKey: "ActiveSubscription")
//        
//        // Post notification about successful purchase
//        NotificationCenter.default.post(name: NSNotification.Name("PremiumContentUnlocked"), object: nil)
//        
//        purchaseCompletion?(.success(true))
//    }
//    
//    private func handleFailedTransaction(_ transaction: SKPaymentTransaction) {
//        defer {
//            SKPaymentQueue.default().finishTransaction(transaction)
//        }
//        
//        purchaseCompletion?(.failure(transaction.error ?? SubscriptionError.unknownError))
//    }
//    
//    private func handleRestoredTransaction(_ transaction: SKPaymentTransaction) {
//        defer {
//            SKPaymentQueue.default().finishTransaction(transaction)
//        }
//        
//        guard let subscriptionType = SubscriptionType(rawValue: transaction.payment.productIdentifier) else {
//            restoreCompletion?(.failure(SubscriptionError.invalidProductIdentifier))
//            return
//        }
//        
//        activeSubscription = subscriptionType
//        UserDefaults.standard.set(subscriptionType.rawValue, forKey: "ActiveSubscription")
//        
//        // Post notification about restored purchase
//        NotificationCenter.default.post(name: NSNotification.Name("PremiumContentUnlocked"), object: nil)
//    }
//    
//    // MARK: - Restore Completed
//    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
//        restoreCompletion?(.success(!queue.transactions.isEmpty))
//    }
//    
//    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
//        restoreCompletion?(.failure(error))
//    }
//}
//
//// Custom Error Types
//enum SubscriptionError: Error {
//    case productNotFound
//    case invalidProductIdentifier
//    case unknownError
//}
//
//// MARK: - Completion Handlers (Weak to avoid retain cycles)
//private extension SubscriptionManager {
//    var productsRequestCompletion: ((Result<[SKProduct], Error>) -> Void)? {
//        get { objc_getAssociatedObject(self, &productsRequestCompletionKey) as? (Result<[SKProduct], Error>) -> Void }
//        set { objc_setAssociatedObject(self, &productsRequestCompletionKey, newValue, .OBJC_ASSOCIATION_COPY) }
//    }
//    
//    var purchaseCompletion: ((Result<Bool, Error>) -> Void)? {
//        get { objc_getAssociatedObject(self, &purchaseCompletionKey) as? (Result<Bool, Error>) -> Void }
//        set { objc_setAssociatedObject(self, &purchaseCompletionKey, newValue, .OBJC_ASSOCIATION_COPY) }
//    }
//    
//    var restoreCompletion: ((Result<Bool, Error>) -> Void)? {
//        get { objc_getAssociatedObject(self, &restoreCompletionKey) as? (Result<Bool, Error>) -> Void }
//        set { objc_setAssociatedObject(self, &restoreCompletionKey, newValue, .OBJC_ASSOCIATION_COPY) }
//    }
//}
//
//// Private keys for associated objects
//private var productsRequestCompletionKey: UInt8 = 0
//private var purchaseCompletionKey: UInt8 = 0
//private var restoreCompletionKey: UInt8 = 0
//
//// PremiumManager.swift (Updated)
//class PremiumManager {
//    static let shared = PremiumManager()
//    
//    func isContentUnlocked(itemID: Int) -> Bool {
//        return SubscriptionManager.shared.checkSubscriptionStatus()
//    }
//    
//    func unlockWeeklyContent() {
//        // Any additional logic for weekly content
//    }
//    
//    func unlockMonthlyContent() {
//        // Any additional logic for monthly content
//    }
//    
//    func unlockAllContent() {
//        // Any additional logic for yearly/lifetime content
//    }
//}
