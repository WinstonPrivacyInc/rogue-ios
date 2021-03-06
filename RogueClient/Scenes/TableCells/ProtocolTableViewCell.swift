//
//  ProtocolTableViewCell.swift
//  Rogue iOS app
//  https://github.com/WinstonPrivacyInc/rogue-ios
//
//  Created by Fedir Nepyyvoda
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

// TODO - antonio - remove this class
//import UIKit
//
//class ProtocolTableViewCell: UITableViewCell {
//
//    @IBOutlet weak var protocolLabel: UILabel!
//    @IBOutlet weak var protocolSettingsLabel: UILabel!
//
//    private var protocolLabelText: String {
//        if !UIDevice.screenHeightLargerThan(device: .iPhones55s5cSE) { return "Protocol & port" }
//        return "Preferred protocol & port"
//    }
//
//    // MARK: - Methods -
//
//    func setup(connectionProtocol: ConnectionSettings, isSettings: Bool) {
//        var title = connectionProtocol.formatTitle()
//        var isChecked = connectionProtocol.tunnelType() == Application.shared.settings.connectionProtocol.tunnelType()
//
//        if isSettings {
//            title = connectionProtocol.formatProtocol()
//            isChecked = connectionProtocol == Application.shared.settings.connectionProtocol
//        }
//
//        if connectionProtocol == .openvpn(.udp, 0) || connectionProtocol == .wireguard(.udp, 0) {
//            setupSelectAction(title: protocolLabelText)
//        } else if connectionProtocol == .wireguard(.udp, 2) {
//            setupAction(title: "WireGuard details")
//        } else {
//            updateLabel(title: title, isChecked: isChecked)
//        }
//
//        tintColor = UIColor.init(named: Theme.appPrimary)
//    }
//
//    private func updateLabel(title: String, isChecked: Bool) {
//        protocolLabel.text = title
//        protocolSettingsLabel.text = ""
//
//        if isChecked {
//            accessoryType = .checkmark
//        } else {
//            accessoryType = .none
//        }
//    }
//
//    private func setupSelectAction(title: String) {
//        protocolLabel.text = title
//        protocolSettingsLabel.text = Application.shared.settings.connectionProtocol.formatProtocol()
//        accessoryType = .disclosureIndicator
//    }
//
//    private func setupAction(title: String) {
//        protocolLabel.text = title
//        protocolSettingsLabel.text = ""
//        accessoryType = .disclosureIndicator
//    }
//
//}
