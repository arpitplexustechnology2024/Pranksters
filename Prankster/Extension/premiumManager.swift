//
//  premiumManager.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 14/11/24.
//

import Foundation

class PremiumManager {
    static let shared = PremiumManager()
    private let defaults = UserDefaults.standard

    private let subscriptionActiveKey = "isSubscriptionActive"
    private let subscriptionExpirationDateKey = "subscriptionExpirationDate"
    private let allUnlockedKey = "allContentUnlocked"

    private var temporarilyUnlockedContent: Set<Int> = []
    
    var isSubscriptionActive: Bool {
        guard let expirationDate = defaults.object(forKey: subscriptionExpirationDateKey) as? Date else {
            return false
        }
        
        return expirationDate > Date()
    }
    
    func setSubscription(expirationDate: Date) {
        defaults.set(true, forKey: subscriptionActiveKey)
        defaults.set(expirationDate, forKey: subscriptionExpirationDateKey)
    }
    
    func clearSubscription() {
        defaults.removeObject(forKey: subscriptionActiveKey)
        defaults.removeObject(forKey: subscriptionExpirationDateKey)
    }
    
    func isContentUnlocked(itemID: Int) -> Bool {
        if defaults.bool(forKey: allUnlockedKey) {
            return true
        }
        
        if isSubscriptionActive {
            return true
        }

        return temporarilyUnlockedContent.contains(itemID)
    }

    func temporarilyUnlockContent(itemID: Int) {
        temporarilyUnlockedContent.insert(itemID)
    }

    func clearTemporaryUnlocks() {
        temporarilyUnlockedContent.removeAll()
    }
    
    func checkSubscriptionStatus() {
        guard let expirationDate = defaults.object(forKey: subscriptionExpirationDateKey) as? Date else {
            return
        }
        
        if expirationDate <= Date() {
            clearSubscription()
            clearTemporaryUnlocks()
        }
    }
}


import Foundation
import UIKit
import StoreKit
import Alamofire

class PremiumManagerr {
    static let shared = PremiumManagerr()
    private let defaults = UserDefaults.standard
    
    private let allUnlockedKey = "allContentUnlocked"
    private let weeklyUnlockedKey = "weeklyContentUnlocked"
    private let monthlyUnlockedKey = "monthlyContentUnlocked"
    private let yearlyUnlockedKey = "yearlyContentUnlocked"
    private let premiumExpirationKey = "premiumExpirationDate"
    
    private var temporarilyUnlockedContent: Set<Int> = []
    
    private init() {}
    
    func isContentUnlocked(itemID: Int) -> Bool {

        if defaults.bool(forKey: allUnlockedKey) {
            return true
        }
        
        if isWeeklyPremiumActive() || isMonthlyPremiumActive() || isYearlyPremiumActive() {
            return true
        }
        
        return temporarilyUnlockedContent.contains(itemID)
    }
    
    func temporarilyUnlockContent(itemID: Int) {
        temporarilyUnlockedContent.insert(itemID)
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
    
    func unlockYearlyContent() {
        let expirationDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())
        defaults.set(true, forKey: yearlyUnlockedKey)
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
    
    func isYearlyPremiumActive() -> Bool {
        guard let expirationDate = defaults.object(forKey: premiumExpirationKey) as? Date else {
            return false
        }
        return defaults.bool(forKey: yearlyUnlockedKey) && expirationDate > Date()
    }
    
    func clearTemporaryUnlocks() {
        temporarilyUnlockedContent.removeAll()
        defaults.removeObject(forKey: weeklyUnlockedKey)
        defaults.removeObject(forKey: monthlyUnlockedKey)
        defaults.removeObject(forKey: yearlyUnlockedKey)
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
