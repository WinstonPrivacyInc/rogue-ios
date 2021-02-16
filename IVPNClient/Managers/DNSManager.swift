//
//  DNSManager.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2021-02-16.
//  Copyright (c) 2021 Privatus Limited.
//
//  This file is part of the IVPN iOS app.
//
//  The IVPN iOS app is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The IVPN iOS app is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License
//  along with the IVPN iOS app. If not, see <https://www.gnu.org/licenses/>.
//

import Foundation
import NetworkExtension

@available(iOS 14.0, *)
class DNSManager {
    
    // MARK: - Properties -
    
    static let shared = DNSManager()
    
    var isEnabled: Bool {
        return manager.isEnabled
    }
    
    private let manager = NEDNSSettingsManager.shared()
    
    // MARK: - Initialize -
    
    private init() {}
    
    // MARK: - Methods -
    
    func saveProfile(model: SecureDNS, completion: @escaping (Error?) -> ()) {
        manager.loadFromPreferences { _ in
            self.manager.dnsSettings = self.getDnsSettings(model: model)
            self.manager.onDemandRules = self.getOnDemandRules(model: model)
            self.manager.saveToPreferences { error in
                completion(error)
            }
        }
    }
    
    func removeProfile(completion: @escaping (Error?) -> ()) {
        manager.removeFromPreferences { error in
            completion(error)
        }
    }
    
    // MARK: - Private methods -
    
    private func getDnsSettings(model: SecureDNS) -> NEDNSSettings {
        let ipAddress = model.ipAddress ?? ""
        let type = SecureDNSType.init(rawValue: model.type)

        if type == .dot {
            let dnsSettings = NEDNSOverTLSSettings(servers: [ipAddress])
            dnsSettings.serverName = "" // TODO: Implement serverName
            return dnsSettings
        } else {
            let dnsSettings = NEDNSOverHTTPSSettings(servers: [ipAddress])
            dnsSettings.serverURL = URL.init(string: "") // TODO: Implement serverURL
            return dnsSettings
        }
    }
    
    private func getOnDemandRules(model: SecureDNS) -> [NEOnDemandRule] {
        var onDemandRules: [NEOnDemandRule] = []
        
        let mobileNetworkRule = model.mobileNetwork ? NEOnDemandRuleConnect() : NEOnDemandRuleDisconnect()
        mobileNetworkRule.interfaceTypeMatch = .cellular
        onDemandRules.append(mobileNetworkRule)
        
        let wifiNetworkRule = model.wifiNetwork ? NEOnDemandRuleConnect() : NEOnDemandRuleDisconnect()
        wifiNetworkRule.interfaceTypeMatch = .wiFi
        onDemandRules.append(wifiNetworkRule)
        
        onDemandRules.append(NEOnDemandRuleConnect())
        
        return onDemandRules
    }
    
}