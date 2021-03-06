//
//  MainViewController.swift
//  Rogue iOS app
//  https://github.com/WinstonPrivacyInc/rogue-ios
//
//  Created by Juraj Hilje on 2020-02-19.
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
import FloatingPanel
import NetworkExtension
import Amplify

class MainViewController: UIViewController {
    
    // MARK: - @IBOutlets -
    
    @IBOutlet weak var mainView: MainView!
    
    // MARK: - Properties -
    
    var floatingPanel: FloatingPanelController!
    private var updateServerListDidComplete = false
    private var updateServersTimer = Timer()
    private var vpnErrorObserver = VPNErrorObserver()
    
    // MARK: - @IBActions -
    
    @IBAction func openSettings(_ sender: UIButton) {
        presentSettingsScreen()
        
        if let controlPanelViewController = floatingPanel.contentViewController {
            NotificationCenter.default.removeObserver(controlPanelViewController, name: Notification.Name.TermsOfServiceAgreed, object: nil)
            NotificationCenter.default.removeObserver(controlPanelViewController, name: Notification.Name.NewSession, object: nil)
            NotificationCenter.default.removeObserver(controlPanelViewController, name: Notification.Name.ForceNewSession, object: nil)
        }
        
        NotificationCenter.default.post(name: Notification.Name.HideConnectToServerPopup, object: nil)
    }
    
    @IBAction func openAccountInfo(_ sender: UIButton) {
        evaluateIsSignedIn { (isSignedIn) in
            if isSignedIn {
                DispatchQueue.main.async {
                    self.presentAccountScreen()
                }
            }
        }
    }
    
    // MARK: - View lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.accessibilityIdentifier = "mainScreen"
        initErrorObservers()
        initFloatingPanel()
        addObservers()
        startServersUpdate()
        startVPNStatusObserver()
    }
    
    private func listenForAuthEvents() {
        // Assumes `unsubscribeToken` is declared as an instance variable in your view
         _ = Amplify.Hub.listen(to: .auth) { payload in
            Application.shared.authentication.getUserAttribute(key: .email) { (email) in
                KeyChain.username = email ?? ""
            }
         }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startPingService(updateServerListDidComplete: updateServerListDidComplete)
        refreshUI()
        initConnectionInfo()
    }
    
    deinit {
        updateServersTimer.invalidate()
        Application.shared.connectionManager.removeStatusChangeUpdates()
    }
    
    // MARK: - Segues -
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ControlPanelSelectServer" {
            if let navController = segue.destination as? UINavigationController {
                if let viewController = navController.topViewController as? ServerViewController {
                    viewController.serverDelegate = floatingPanel.contentViewController as! ControlPanelViewController
                }
            }
        }
        
        if segue.identifier == "ControlPanelSelectExitServer" {
            if let navController = segue.destination as? UINavigationController {
                if let viewController = navController.topViewController as? ServerViewController {
                    viewController.isExitServer = true
                }
            }
        }
    }
    
    // MARK: - Interface Orientations -
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        floatingPanel.updateLayout()
        mainView.updateLayout()
    }
    
    // MARK: - Methods -
    
    func refreshUI() {
        updateFloatingPanelLayout()
    }
    
    func updateStatus(vpnStatus: NEVPNStatus, animated: Bool = true) {
        mainView.updateStatus(vpnStatus: vpnStatus)
        
        if let controlPanelViewController = self.floatingPanel.contentViewController as? ControlPanelViewController {
            controlPanelViewController.updateStatus(vpnStatus: vpnStatus, animated: animated)
        }
        
        Application.shared.connectionManager.statusModificationDate = Date()
    }
    
    @objc func updateGeoLocation() {
        guard let controlPanelViewController = self.floatingPanel.contentViewController as? ControlPanelViewController else {
            return
        }
        
        controlPanelViewController.controlPanelView.connectionInfoDisplayMode = .loading
        
        GeoService.shared.geoLookUp { result in
            guard let geoInformation = result else {
                controlPanelViewController.controlPanelView.connectionInfoDisplayMode = .error
                self.mainView.infoAlertViewModel.infoAlert = .connectionInfoFailure
                self.mainView.updateInfoAlert()
                return
            }
            
            let viewModel = ProofsViewModel(model: geoInformation)
            controlPanelViewController.connectionViewModel = viewModel
            self.mainView.connectionViewModel = viewModel
            self.mainView.infoAlertViewModel.infoAlert = .subscriptionExpiration
            self.mainView.updateInfoAlert()
            
            Application.shared.geoLookup = geoInformation
        }
    }
    
    func expandFloatingPanel() {
        floatingPanel.move(to: .full, animated: true)
    }
    
    // MARK: - Observers -
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateFloatingPanelLayout), name: Notification.Name.UpdateFloatingPanelLayout, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(vpnConfigurationDisabled), name: Notification.Name.VPNConfigurationDisabled, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionActivated), name: Notification.Name.SubscriptionActivated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateGeoLocation), name: Notification.Name.UpdateGeoLocation, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(signOutSuccess), name: Notification.Name.SignOutSuccess, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(signInSuccess), name: Notification.Name.SignInSuccess, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(openSubscriptionSelectionScreen), name: Notification.Name.OpenSubscriptionSelectionScreen, object: nil)
    }
    
    // MARK: - Private methods -
    
    @objc private func openSubscriptionSelectionScreen() {
        self.present(NavigationManager.getSelectSubscriptionViewController(), animated: true, completion: nil)
    }
    
    @objc private func signOutSuccess() {
        showFlashNotification(message: "You have been signed out", presentInView: self.mainView)
    }
    
    @objc private func signInSuccess() {
        showFlashNotification(message: "You have been signed in", presentInView: self.mainView)
    }
    
    @objc private func updateFloatingPanelLayout() {
        floatingPanel.updateLayout()
        mainView.setupView(animated: false)
    }
    
    @objc private func updateServersList() {
        ApiService.shared.getServersList(storeInCache: true) { result in
            self.updateServerListDidComplete = true
            switch result {
            case .success(let serverList):
                Application.shared.serverList = serverList
                Pinger.shared.serverList = Application.shared.serverList
                DispatchQueue.async {
                    Pinger.shared.ping()
                }
            default:
                break
            }
        }
    }
    
    @objc private func vpnConfigurationDisabled() {
        updateStatus(vpnStatus: Application.shared.connectionManager.status)
    }
    
    @objc private func subscriptionActivated() {
        mainView.infoAlertViewModel.infoAlert = .subscriptionExpiration
        mainView.updateInfoAlert()
    }
    
    private func initFloatingPanel() {
        floatingPanel = FloatingPanelController()
        floatingPanel.setup()
        floatingPanel.delegate = self
        floatingPanel.addPanel(toParent: self)
        floatingPanel.show(animated: true)
    }
    
    private func startServersUpdate() {
        // updateServersList() // TODO antonio - come back here after you have an API that will return the available serveres
        updateServersTimer = Timer.scheduledTimer(timeInterval: 60 * 15, target: self, selector: #selector(updateServersList), userInfo: nil, repeats: true)
    }
    
    private func startPingService(updateServerListDidComplete: Bool) {
        if updateServerListDidComplete {
            DispatchQueue.delay(0.5) {
                Pinger.shared.ping()
            }
        }
    }
    
    private func startVPNStatusObserver() {
        Application.shared.connectionManager.getStatus { _, status in
            self.updateStatus(vpnStatus: status, animated: false)
            
            Application.shared.connectionManager.onStatusChanged { status in
                self.updateStatus(vpnStatus: status)
            }
        }
    }
    
    private func initErrorObservers() {
        vpnErrorObserver.delegate = self
    }
    
    private func initConnectionInfo() {
        if !NetworkManager.shared.isNetworkReachable {
            mainView.infoAlertViewModel.infoAlert = .connectionInfoFailure
            mainView.updateInfoAlert()
        }
        
        if Application.shared.connectionManager.status == .invalid {
            updateGeoLocation()
        }
        
        if UserDefaults.standard.bool(forKey: "-UITests") {
            updateGeoLocation()
        }
    }
    
}
