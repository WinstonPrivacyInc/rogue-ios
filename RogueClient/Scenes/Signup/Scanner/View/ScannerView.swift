//
//  ScannerView.swift
//  Rogue iOS app
//  https://github.com/WinstonPrivacyInc/rogue-ios
//
//  Created by Juraj Hilje on 2020-04-08.
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

class ScannerView: UIView {
    
    // MARK: - @IBOutlets -
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var qrView: UIView!
    
    // MARK: - View lifecycle -
    
    override func awakeFromNib() {
        setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupLabel()
    }
    
    // MARK: - Methods -
    
    private func setupView() {
        backgroundColor = UIColor.init(named: Theme.ivpnBackgroundPrimary)
    }
    
    private func setupLabel() {
        // textLabel.textWithIcon(prefix: "Find your QR code under the User Profile menu", image: UIImage.init(named: "icon-user"), sufix: "on any other device with IVPN installed and scan it")
    }
    
}
