//
//  RegistrationViewModel.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 09/10/24.
//

import Foundation

class RegistrationViewModel {
    var registrationResponse: Registration?
    var errorMessage: String?

    // Check if the user has already registered
    func isUserRegistered() -> Bool {
        return UserDefaults.standard.bool(forKey: "isUserRegistered")
    }
    
    // Mark the user as registered
    func markUserAsRegistered() {
        UserDefaults.standard.set(true, forKey: "isUserRegistered")
    }

    // Make API call only if the user is not registered
    func registerUserIfNeeded(completion: @escaping (Bool) -> Void) {
        if isUserRegistered() {
            completion(false)  // User is already registered, skip API call
            return
        }
        
        // Call the API to register
        APIManager.shared.registerUser(premium: false) { result in
            switch result {
            case .success(let response):
                self.registrationResponse = response
                // Only proceed if the status is 1
                if response.status == 1 {
                    self.markUserAsRegistered()  // Mark as registered on success
                    completion(true)
                } else {
                    // Status is not 1, return false to trigger refresh button
                    completion(false)
                }
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                completion(false)
            }
        }
    }
}
