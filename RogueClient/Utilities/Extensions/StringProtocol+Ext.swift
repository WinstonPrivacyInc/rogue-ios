//
//  StringProtocol+Ext.swift
//  Rogue iOS app
//  https://github.com/WinstonPrivacyInc/rogue-ios
//
//  Created by Juraj Hilje on 2019-06-11.
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

import Foundation

extension StringProtocol where Index == String.Index {
    
    func substring(from start: String, to end: String? = nil, options: String.CompareOptions = []) -> SubSequence? {
        guard let lower = range(of: start, options: options)?.upperBound else { return nil }
        guard let end = end else { return self[lower...] }
        guard let upper = self[lower...].range(of: end, options: options)?.lowerBound else { return nil }
        return self[lower..<upper]
    }
    
}
