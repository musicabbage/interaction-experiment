//
//  DateFormatterExtensions.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/7/4.
//

import Foundation

extension DateFormatter {
    static let logDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        //04/07/2023 - 17:29:30
        dateFormatter.dateFormat = "dd/MM/yyyy' - 'HH:mm:ss"
        return dateFormatter
    }()
    
    static let logFileDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        //"yyyy-MM-dd - HH-mm-ss"
        dateFormatter.dateFormat = "yyyy-MM-dd - HH-mm-ss"
        return dateFormatter
    }()
}
