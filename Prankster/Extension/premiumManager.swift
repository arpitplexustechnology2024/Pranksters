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
    private let allUnlockedKey = "allContentUnlocked"
    

    private var temporarilyUnlockedContent: Set<Int> = []
    
    func isContentUnlocked(itemID: Int) -> Bool {

        if defaults.bool(forKey: allUnlockedKey) {
            return true
        }

        return temporarilyUnlockedContent.contains(itemID)
    }
    
    func temporarilyUnlockContent(itemID: Int) {
        temporarilyUnlockedContent.insert(itemID)
    }
    
    func unlockAllContent() {
        defaults.set(true, forKey: allUnlockedKey)
    }

    func clearTemporaryUnlocks() {
        temporarilyUnlockedContent.removeAll()
    }
}

