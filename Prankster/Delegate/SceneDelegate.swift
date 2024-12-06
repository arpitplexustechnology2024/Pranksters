//
//  SceneDelegate.swift
//  Prankster
//
//  Created by Arpit iOS Dev. on 04/12/24.
//

import UIKit
import FBSDKCoreKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    enum ActionType: String {
        case prankAction     = "PrankAction"
        case spinnerAction   = "SpinnerAction"
        case moreAction      = "MoreAction"
    }

    var window: UIWindow?
    var savedShortCutItem: UIApplicationShortcutItem!

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let shortcutItem = connectionOptions.shortcutItem {
            savedShortCutItem = shortcutItem
        }
        guard let _ = (scene as? UIWindowScene) else { return }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        for urlContext in URLContexts {
            ApplicationDelegate.shared.application(UIApplication.shared, open: urlContext.url, options: [:])
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        if savedShortCutItem != nil {
            _ = handleShortCutItem(shortcutItem: savedShortCutItem)
            savedShortCutItem = nil
        }
        // Call checkForUpdate when the scene becomes active
        (UIApplication.shared.delegate as? AppDelegate)?.checkForUpdate()
    }
    
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        let handled = handleShortCutItem(shortcutItem: shortcutItem)
        completionHandler(handled)
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    func handleShortCutItem(shortcutItem: UIApplicationShortcutItem) -> Bool {
        if let actionTypeValue = ActionType(rawValue: shortcutItem.type) {
            switch actionTypeValue {
            case .prankAction:
                self.navigateToLaunchVC(actionKey: "PrankActionKey")
            case .spinnerAction:
                self.navigateToLaunchVC(actionKey: "SpinnerActionKey")
            case .moreAction:
                self.navigateToLaunchVC(actionKey: "MoreActionKey")
            }
        }
        return true
    }
    
    func navigateToLaunchVC(actionKey: String) {
        if let navVC = window?.rootViewController as? UINavigationController,
           let launchVC = navVC.viewControllers.first as? LaunchVC {
            launchVC.passedActionKey = actionKey
        }
    }
}
