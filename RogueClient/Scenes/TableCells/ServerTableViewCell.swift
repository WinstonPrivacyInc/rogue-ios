//
//  ServerTableViewCell.swift
//  Rogue iOS app
//  https://github.com/WinstonPrivacyInc/rogue-ios
//
//  Created by Fedir Nepyyvoda on 2016-10-16.
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

class ServerTableViewCell: UITableViewCell {
    
    @IBOutlet weak var flagImage: FlagImageView!
    @IBOutlet weak var checkImage: UIImageView!
    @IBOutlet weak var serverLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var serverName: UILabel!
    @IBOutlet weak var pingImage: UIImageView!
    @IBOutlet weak var pingTimeMs: UILabel!
    @IBOutlet weak var configureButton: UIButton!
    
    var viewModel: VPNServerViewModel! {
        didSet {
            if !isMultiHop && indexPath.row == 0 {
                flagImage.image = UIImage(named: "icon-fastest-server")
                flagImage.image?.accessibilityIdentifier = "icon-fastest-server"
                serverName.text = "Fastest server"
                configureButton.isHidden = false
                configureButton.isUserInteractionEnabled = true
            } else if isMultiHop && indexPath.row == 0 || !isMultiHop && indexPath.row == 1 {
                flagImage.image = UIImage(named: "icon-shuffle")
                flagImage.image?.accessibilityIdentifier = "icon-shuffle"
                serverName.text = "Random server"
                configureButton.isHidden = true
                configureButton.isUserInteractionEnabled = true
            } else {
                let sort = ServersSort.init(rawValue: UserDefaults.shared.serversSort) ?? .city
                flagImage.image = viewModel.imageForCountryCode
                flagImage.image?.accessibilityIdentifier = ""
                serverName.text = viewModel.formattedServerName(sort: sort)
                configureButton.isHidden = true
                configureButton.isUserInteractionEnabled = false
            }
            flagImage.updateUpFlagIcon()
            serverName.sizeToFit()
            
            if let pingMs = viewModel.server.pingMs {
                if pingMs == -1 {
                    pingTimeMs.text = "Offline"
                } else {
                    pingTimeMs.text = "\(pingMs)ms"
                }
                pingImage.image = viewModel.imageForPingTime
                pingImage.isHidden = false
                pingTimeMs.isHidden = false
                pingTimeMs.sizeToFit()
            } else {
                pingImage.isHidden = true
                pingTimeMs.isHidden = true
            }
        }
    }
    
    var serverToValidate: VPNServer! {
        didSet {
            if !Application.shared.serverList.validateServer(firstServer: viewModel.server, secondServer: serverToValidate) {
                serverName.textColor = UIColor.init(named: Theme.ivpnLabel6)
                flagImage.alpha = 0.5
            } else {
                serverName.textColor = UIColor.init(named: Theme.ivpnLabelPrimary)
                flagImage.alpha = 1
            }
        }
    }
    
    var selectedServer: VPNServer! {
        didSet {
            checkImage.isHidden = true
            
            if !isMultiHop && indexPath.row == 0 && selectedServer.fastest {
                checkImage.isHidden = false
            }
            
            if !isMultiHop && indexPath.row == 1 && selectedServer.random {
                checkImage.isHidden = false
            }
            
            if isMultiHop && indexPath.row == 0 && selectedServer.random {
                checkImage.isHidden = false
            }
            
            if viewModel.server == selectedServer && !selectedServer.fastest && !selectedServer.random {
                checkImage.isHidden = false
            }
        }
    }
    
    var indexPath: IndexPath! {
        didSet {
            if indexPath.row == 0 || !isMultiHop && indexPath.row == 1 {
                pingImage.isHidden = true
                pingTimeMs.isHidden = true
            }
        }
    }
    
    var isMultiHop: Bool!
    
}
