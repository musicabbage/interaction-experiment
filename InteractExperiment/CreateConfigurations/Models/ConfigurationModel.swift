//
//  ConfigurationModel.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/6/4.
//

import Foundation

struct ConfigurationModel {
    let id: String
    var instruction: String = """
When you are ready to start, press 'N' to open the recording pad.\n
When you are finished drawing, press ESC to close the recording pad.
"""
    var familiarImages: [String] = []
    var stimulusImages: [String] = []
    var folderURL: URL {
        FileManager.documentsDirectory.appending(path: id, directoryHint: .isDirectory)
    }
}

extension ConfigurationModel {
    static var mock: ConfigurationModel {
        ConfigurationModel(id: UUID().uuidString)
    }
}
