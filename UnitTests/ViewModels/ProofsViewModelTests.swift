//
//  ProofsViewModelTests.swift
//  Rogue iOS app
//  https://github.com/WinstonPrivacyInc/rogue-ios
//
//  Created by Juraj Hilje on 2020-06-30.
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

import XCTest

@testable import RogueClient

class ProofsViewModelTests: XCTestCase {
    
    var viewModel = ProofsViewModel(model: GeoLookup(ipAddress: "0.0.0.0", countryCode: "DE", country: "Germany", city: "Berlin", isp: "ISP Provider", latitude: 0, longitude: 0))
    
    override func setUp() {
        viewModel.model = GeoLookup(ipAddress: "0.0.0.0", countryCode: "DE", country: "Germany", city: "Berlin", isp: "ISP Provider", latitude: 0, longitude: 0)
    }
    
    func test_imageNameForCountryCode() {
        XCTAssertEqual(viewModel.imageNameForCountryCode, "DE")
    }
    
    func test_ipAddress() {
        XCTAssertEqual(viewModel.ipAddress, "0.0.0.0")
    }
    
    func test_city() {
        XCTAssertEqual(viewModel.city, "Berlin")
    }
    
    func test_countryCode() {
        XCTAssertEqual(viewModel.countryCode, "DE")
    }
    
    func test_provider() {
        XCTAssertEqual(viewModel.provider, "ISP Provider")
        
        viewModel.model = GeoLookup(ipAddress: "0.0.0.0", countryCode: "DE", country: "Germany", city: "Berlin", isp: "ISP Provider", latitude: 0, longitude: 0)
        XCTAssertEqual(viewModel.provider, "IVPN")
    }
    
}
