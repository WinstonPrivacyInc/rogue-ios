//
//  APIAccessManagerTests.swift
//  Rogue iOS app
//  https://github.com/WinstonPrivacyInc/rogue-ios
//
//  Created by Juraj Hilje on 2019-08-20.
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

class APIAccessManagerTests: XCTestCase {
    
    override func setUp() {
        UserDefaults.shared.removeObject(forKey: UserDefaults.Key.apiHostName)
        UserDefaults.shared.set(["1.1.1.1"], forKey: UserDefaults.Key.hostNames)
    }
    
    override func tearDown() {
        UserDefaults.shared.removeObject(forKey: UserDefaults.Key.hostNames)
        UserDefaults.shared.removeObject(forKey: UserDefaults.Key.apiHostName)
    }
    
    func test_nextHostName() {
        let currentHost = UserDefaults.shared.apiHostName
        if let nextHost = APIAccessManager.shared.nextHostName(failedHostName: currentHost) {
            XCTAssertEqual(nextHost, "1.1.1.1")
        } else {
            XCTFail("Hostname not found")
        }
    }
    
}
