//
//  AppDelegate.swift
//  Prankster
//
//  Created by Arpit iOS Dev. on 04/12/24.
//

import UIKit
import FirebaseCore
import UserNotifications
import OneSignalFramework
import FBSDKCoreKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        getAndStoreOneSignalPlayerId()
        OneSignal.Debug.setLogLevel(.LL_VERBOSE)
        OneSignal.initialize("d8e64d76-dc16-444f-af2d-1bb802f7bc44", withLaunchOptions: launchOptions)
        checkNotificationAuthorization()
        return true
    }
    
    // MARK: - Notification Authorization
    func checkNotificationAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                self.requestNotificationPermission()
            case .denied:
                self.requestNotificationPermission()
            case .authorized:
                print("Notifications already authorized")
            default:
                break
            }
        }
    }
    
    func requestNotificationPermission() {
        OneSignal.Notifications.requestPermission({ accepted in
            print("User accepted notifications: \(accepted)")
        }, fallbackToSettings: true)
    }
    
    // MARK: - Core Functionality
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .portrait
        }
        return .all
    }
    
    func getAndStoreOneSignalPlayerId() {
        if let playerId = OneSignal.User.pushSubscription.id {
            print("OneSignal Player ID: \(playerId)")
            UserDefaults.standard.set(playerId, forKey: "SubscriptionID")
        } else {
            print("Failed to get OneSignal Player ID")
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Device registered for push notifications")
        getAndStoreOneSignalPlayerId()
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return ApplicationDelegate.shared.application(app, open: url, options: options)
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        checkNotificationAuthorization()
    }
}

