//
//  AccountView.swift
//  Rogue iOS app
//  https://github.com/WinstonPrivacyInc/rogue-ios
//
//  Created by Juraj Hilje on 2020-03-30.
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

class AccountView: UITableView {
    
    @IBOutlet weak var accountIdLabel: UILabel!
    @IBOutlet weak var signOutButton: UIButton!
    
    
//    @IBOutlet weak var qrCodeImage: UIImageView!
//    @IBOutlet weak var statusLabel: UILabel!
//    @IBOutlet weak var subscriptionLabel: UILabel!
//    @IBOutlet weak var activeUntilLabel: UILabel!
//    @IBOutlet weak var planLabel: UILabel!
//    @IBOutlet weak var planDescriptionHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Properties -
    
    private var serviceType: ServiceType = Application.shared.serviceStatus.currentPlan == "IVPN Pro" ? .pro : .standard
    
    // MARK: - Methods -
    
    func setupView(viewModel: AccountViewModel) {
        // accountIdLabel.text = viewModel.accountId

        //        statusLabel.text = viewModel.statusText
//        statusLabel.backgroundColor = viewModel.statusColor

        //        subscriptionLabel.text = viewModel.subscriptionText
//        activeUntilLabel.text = viewModel.activeUntilText
//        planLabel.textColor = .white
        
//        switch serviceType {
//        case .standard:
//            break
//        case .pro:
//            planLabel.text = "Login to the website to change subscription plan"
//            planLabel.font = .systemFont(ofSize: 12, weight: .regular)
//            planDescriptionHeightConstraint.constant = 58
//        }
        
    }
    
    func initQRCode(viewModel: AccountViewModel) {
        // qrCodeImage.image = UIImage.generateQRCode(from: viewModel.accountId)
    }
    
}
