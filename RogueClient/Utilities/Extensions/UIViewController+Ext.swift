//
//  UIViewController+Ext.swift
//  Rogue iOS app
//  https://github.com/WinstonPrivacyInc/rogue-ios
//
//  Created by Juraj Hilje on 2018-10-10.
//  Copyright (c) 2020 Privatus Limited.
//
//  This file is part of the Rogue iOS app.
//
//  The Rogue iOS app is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The Rogue iOS app is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License
//  along with the Rogue iOS app. If not, see <https://www.gnu.org/licenses/>.
//

import UIKit
import SafariServices
import MessageUI

extension UIDevice {
    var hasNotch: Bool {
        let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        return bottom > 0
    }
}

extension UIViewController {
    
    // MARK: - Properties -
    
    var isPresentedModally: Bool {
        if let navigationController = navigationController {
            if navigationController.viewControllers.first != self {
                return false
            }
        }
        
        if presentingViewController != nil {
            return true
        }
        
        if navigationController?.presentingViewController?.presentedViewController == navigationController {
            return true
        }
        
        if tabBarController?.presentingViewController is UITabBarController {
            return true
        }
        
        return false
    }
    
    // MARK: - @IBActions -
    
    @IBAction func dismissViewController(_ sender: Any) {
        if #available(iOS 13.0, *) {
            if let presentationController = navigationController?.presentationController {
                presentationController.delegate?.presentationControllerDidDismiss?(presentationController)
            }
        }
        navigationController?.dismiss(animated: true)
    }
    
    // MARK: - Methods -
    
    func signOut(deleteSession: Bool = true) {
        if UserDefaults.shared.networkProtectionEnabled {
            UserDefaults.clearSession()
        }
        
        Application.shared.connectionManager.resetRulesAndDisconnectShortcut(closeApp: false)
        Application.shared.connectionManager.removeAll()
        Application.shared.authentication.signOut()
        
        navigationController?.dismiss(animated: true, completion: {
            NotificationCenter.default.post(name: Notification.Name.VPNConfigurationDisabled, object: nil)
            NotificationCenter.default.post(name: Notification.Name.UpdateControlPanel, object: nil)
            NotificationCenter.default.post(name: Notification.Name.SignOutSuccess, object: nil)
        })
    }
    
    func openTermsOfService() {
        openWebPage("https://winstonprivacy.com/pages/terms-of-service")
    }
    
    func openPrivacyPolicy() {
        openWebPage("https://winstonprivacy.com/pages/privacy-policy")
    }
    
    func openSupportPage() {
        openWebPage("https://support.winstonprivacy.com")
    }
    
    func openFeedbackPage() {
        openWebPage("https://feedback.winstonprivacy.com")
    }
    
    func registerUserActivity(type: String, title: String) {
        let activity = NSUserActivity(activityType: type)
        activity.title = title
        activity.isEligibleForSearch = true
        activity.isEligibleForPrediction = true
        
        userActivity = activity
        userActivity?.becomeCurrent()
    }
    
    func hideKeyboardOnTap() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func openWebPage(_ stringURL: String) {
        guard UIApplication.isValidURL(urlString: stringURL) else {
            showErrorAlert(title: "Error", message: "The specified URL has an unsupported scheme. Only HTTP and HTTPS URLs are supported.")
            return
        }
        
        guard let url = URL(string: stringURL) else { return }
        
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true, completion: nil)
    }
    
    func showSubscriptionActivatedAlert(serviceStatus: ServiceStatus, completion: (() -> Void)? = nil) {
        showAlert(
            title: "Thank you!",
            message: "The payment was successfully processed.\nService is active until: " + serviceStatus.activeUntilString(),
            handler: { _ in
                if let completion = completion {
                    completion()
                }
        })
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func selectNetworkTrust(network: Network, sourceView: UIView, completion: @escaping (String) -> Void) {
        var collection = NetworkTrust.allCasesNormal
        
        if network.isDefault {
            collection = NetworkTrust.allCasesDefault
        }
        
        let actions = collection.map { $0.rawValue }
        
        showActionSheet(image: nil, selected: network.trust, largeText: true, centered: true, title: "Network Trust", actions: actions, sourceView: sourceView) { index in
            guard index > -1, actions[index] != network.trust else {
                return
            }
            
            completion(actions[index])
        }
    }
    
    func showReconnectPrompt(sourceView: UIView, confirmed: @escaping () -> Void) {
        guard !UserDefaults.shared.notAskToReconnect else {
            confirmed()
            return
        }
        
        showActionSheet(title: "To apply the new settings, IVPN needs to be reconnected.", actions: ["Reconnect", "Reconnect + Don't ask next time"], sourceView: sourceView) { index in
            switch index {
            case 0:
                confirmed()
            case 1:
                UserDefaults.shared.setValue(true, forKey: UserDefaults.Key.notAskToReconnect)
                confirmed()
            default:
                break
            }
        }
    }
    
    func showDisableVPNPrompt(sourceView: UIView, confirmed: @escaping () -> Void) {
        showActionSheet(title: "VPN connection is active. Changing protocol will turn off the current VPN connection.", actions: ["Continue"], sourceView: sourceView) { index in
            switch index {
            case 0:
                confirmed()
            default:
                break
            }
        }
    }
    
}

// MARK: - Presenter -

extension UIViewController {
    
    func evaluateIsServiceActive() -> Bool {
//        guard Application.shared.serviceStatus.isActive else {
//            let viewController = NavigationManager.getSubscriptionViewController()
//            viewController.presentationController?.delegate = self as? UIAdaptivePresentationControllerDelegate
//            present(viewController, animated: true, completion: nil)
//            return false
//        }
//
//        return true
        
        // antonio - this is temporary to simulate
        if KeyChain.rogueSubscription != nil {
            return true
        } else {
            self.present(NavigationManager.getSelectSubscriptionViewController(), animated: true, completion: nil)
            return false
        }
    }
    
    func deviceCanMakePurchases() -> Bool {
        guard IAPManager.shared.canMakePurchases else {
            showAlert(title: "Error", message: "In-App Purchases are not available on your device.")
            return false
        }
        
        return true
    }
    
}

extension UIViewController: AppKeyManagerDelegate {
    func setKeyStart() {}
    func setKeySuccess() {}
    func setKeyFail() {}
}

extension UIViewController: SessionManagerDelegate {
    func createSessionStart() {}
    func createSessionSuccess() {}
    func createSessionFailure(error: Any?) {}
    func createSessionTooManySessions(error: Any?) {}
    func createSessionAuthenticationError() {}
    func createSessionServiceNotActive() {}
    func createSessionAccountNotActivated(error: Any?) {}
    func deleteSessionStart() {}
    func deleteSessionSuccess() {}
    func deleteSessionFailure() {}
    func deleteSessionSkip() {}
    func sessionStatusSuccess() {}
    func sessionStatusNotFound() {}
    func sessionStatusExpired() {}
    func sessionStatusFailure() {}
    func twoFactorRequired(error: Any?) {}
    func twoFactorIncorrect(error: Any?) {}
    func captchaRequired(error: Any?) {}
    func captchaIncorrect(error: Any?) {}
}

// MARK: - Presenter -

extension UIViewController {
    
    func evaluateIsNetworkReachable() -> Bool {
        guard NetworkManager.shared.isNetworkReachable else {
            showAlert(title: "Connection error", message: "Please check your Internet connection and try again.")
            return false
        }
        
        return true
    }
    
    func evaluateIsLoggedIn() -> Bool {
        guard Application.shared.authentication.isLoggedIn else {
            let viewController = NavigationManager.getSignInViewController()
            viewController.presentationController?.delegate = self as? UIAdaptivePresentationControllerDelegate
            present(viewController, animated: true, completion: nil)
            return false
        }
        
        return true
    }
    
    func evaluateIsSignedIn(completion: @escaping (Bool) -> Void) {
        Application.shared.authentication.isSignedIn { (isSignedIn) in
            DispatchQueue.main.async {
                if !isSignedIn {
                    self.presentSignInView()
                }
                completion(isSignedIn)
            }
        }
    }
    
    func presentSignInView() -> Void {
        let viewController = NavigationManager.getSignInViewController()
        viewController.presentationController?.delegate = self as? UIAdaptivePresentationControllerDelegate
        present(viewController, animated: true, completion: nil)
    }
    
    func evaluateHasUserConsent() -> Bool {
        guard UserDefaults.shared.hasUserConsent else {
            present(NavigationManager.getTermsOfServiceViewController(), animated: true, completion: nil)
            return false
        }
        return true
    }
    
    private func presentTOSView() -> Void {
        
    }
    
    func evaluateMultiHopCapability(_ sender: Any) -> Bool {
        guard Application.shared.serviceStatus.isEnabled(capability: .multihop) else {
            showAlert(title: "", message: "MultiHop is supported only on IVPN Pro plan")
            return false
        }
        
        return true
    }
    
    func evaluateIsOpenVPN() -> Bool {
        if Application.shared.settings.connectionProtocol.tunnelType() != .openvpn {
            showAlert(title: "Change protocol to OpenVPN", message: "For Multi-Hop connection you must select OpenVPN protocol.") { _ in
            }
            return false
        }
        
        return true
    }
    
    func evaluateMailCompose() -> Bool {
        guard MFMailComposeViewController.canSendMail() else {
            showAlert(title: "Cannot send e-mail", message: "Your device cannot send e-mail. Please check e-mail configuration and try again.")
            return false
        }
        
        return true
    }
    
    func presentSettingsScreen() {
        let viewController = NavigationManager.getSettingsViewController()
        viewController.presentationController?.delegate = self as? UIAdaptivePresentationControllerDelegate
        present(viewController, animated: true, completion: nil)
    }
    
    func presentAccountScreen() {
        let viewController = NavigationManager.getAccountViewController()
        viewController.presentationController?.delegate = self as? UIAdaptivePresentationControllerDelegate
        present(viewController, animated: true, completion: nil)
    }
    
}
