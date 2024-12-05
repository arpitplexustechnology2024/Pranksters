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
    
    // Store temporarily unlocked content IDs in memory instead of UserDefaults
    private var temporarilyUnlockedContent: Set<Int> = []
    
    func isContentUnlocked(itemID: Int) -> Bool {
        // Check if all content is unlocked via premium subscription
        if defaults.bool(forKey: allUnlockedKey) {
            return true
        }
        // Check if content is temporarily unlocked via ad
        return temporarilyUnlockedContent.contains(itemID)
    }
    
    func temporarilyUnlockContent(itemID: Int) {
        temporarilyUnlockedContent.insert(itemID)
    }
    
    func unlockAllContent() {
        defaults.set(true, forKey: allUnlockedKey)
    }
    
    // Clear temporary unlocks when app restarts or refreshes
    func clearTemporaryUnlocks() {
        temporarilyUnlockedContent.removeAll()
    }
}

