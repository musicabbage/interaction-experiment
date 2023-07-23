//
//  DateExtensions.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/7/9.
//

import Foundation

extension Date {
    static var timestamp: TimeInterval {
        Date.now.timeIntervalSince1970 * 1000
    }
}
