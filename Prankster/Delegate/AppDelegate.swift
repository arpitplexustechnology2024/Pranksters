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
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        Settings.shared.isAutoLogAppEventsEnabled = true
       // AppEvents.shared.logEvent(AppEvents.Name("fb_mobile_activate_app"))
        FirebaseApp.configure()
        getAndStoreOneSignalPlayerId()
        OneSignal.Debug.setLogLevel(.LL_VERBOSE)
        OneSignal.initialize("d8e64d76-dc16-444f-af2d-1bb802f7bc44", withLaunchOptions: launchOptions)
        checkNotificationAuthorization()
        setupAppLifecycleObservers()
        return true
    }
    
    private func setupAppLifecycleObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc private func appDidEnterBackground() {
        PremiumManager.shared.clearTemporaryUnlocks()
    }
    
    @objc private func appWillEnterForeground() {
        PremiumManager.shared.clearTemporaryUnlocks()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
        return ApplicationDelegate.shared.application(app, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation])
    }
    
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}
    
    // MARK: - Update Check
    func fetchAppStoreVersion(completion: @escaping (String?) -> Void) {
        let appID = "6739135275"
        let urlString = "https://itunes.apple.com/lookup?id=\(appID)"
        
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let results = json["results"] as? [[String: Any]],
                   let appStoreVersion = results.first?["version"] as? String {
                    completion(appStoreVersion)
                } else {
                    completion(nil)
                }
            } catch {
                completion(nil)
            }
        }
        
        task.resume()
    }
    
    func getCurrentAppVersion() -> String? {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }
        return nil
    }
    
    func checkForUpdate() {
        fetchAppStoreVersion { appStoreVersion in
            guard let appStoreVersion = appStoreVersion,
                  let currentVersion = self.getCurrentAppVersion() else {
                return
            }
            
            if appStoreVersion.compare(currentVersion, options: .numeric) == .orderedDescending {
                DispatchQueue.main.async {
                    self.promptUserToUpdate()
                }
            }
        }
    }
    
    func promptUserToUpdate() {
        let alert = UIAlertController(
            title: "Update Available",
            message: "A newer version of the app is available. Please update to the latest version.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { _ in
            self.openAppStoreForUpdate()
        }))
        
        alert.addAction(UIAlertAction(title: "Later", style: .cancel, handler: nil))
        
        if let topController = UIApplication.shared.keyWindow?.rootViewController {
            topController.present(alert, animated: true, completion: nil)
        }
    }
    
    func openAppStoreForUpdate() {
        let appID = "6739135275"
        if let url = URL(string: "https://apps.apple.com/app/id\(appID)") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        checkNotificationAuthorization()
        checkForUpdate()
        Settings.shared.isAutoLogAppEventsEnabled = true
    }
}

