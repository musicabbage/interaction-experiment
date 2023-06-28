//
//  ConfigurationModel.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/6/4.
//

import Foundation

struct ConfigurationModel: Codable, Identifiable, Hashable {
    let id: String
    var isDraft: Bool = false
    var instruction: String = """
When you are ready to start, press 'N' to open the recording pad.\n
When you are finished drawing, press ESC to close the recording pad.
"""
    var familiarImages: [String] = []
    var stimulusImages: [String] = []
    var folderURL: URL {
        let path = isDraft ? "draft/\(id)" : id
        return FileManager.documentsDirectory.appending(path: path, directoryHint: .isDirectory)
    }
    var configURL: URL {
        folderURL.appending(path: "config")
    }
}

extension ConfigurationModel {
    static var mock: ConfigurationModel {
        ConfigurationModel(id: UUID().uuidString)
    }
}
