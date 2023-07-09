//
//  ConfigurationModel.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/6/4.
//

import Foundation

struct ConfigurationModel: Codable, Identifiable, Hashable {
    
    static let configFilename: String = "config"
    
    let id: String
    var isDraft: Bool = false
    var instruction: String
    var familiarImages: [String] = []
    var stimulusImages: [String] = []
    var folderURL: URL {
        let path = isDraft ? "draft/\(id)" : id
        return FileManager.configsDirectory.appending(path: path, directoryHint: .isDirectory)
    }
    var configURL: URL {
        folderURL.appending(path: ConfigurationModel.configFilename)
    }
    
    init(id: String = UUID().uuidString,
         isDraft: Bool = false,
         instruction: String? = nil,
         familiarImages: [String] = [],
         stimulusImages: [String] = []) {
        self.id = id
        self.isDraft = isDraft
        self.instruction = instruction ?? """
When you are ready to start, press 'N' to open the recording pad.\n
When you are finished drawing, press ESC to close the recording pad.
"""
        self.familiarImages = familiarImages
        self.stimulusImages = stimulusImages
    }
}

extension ConfigurationModel {
    static var mock: ConfigurationModel {
        var mock = ConfigurationModel()
        mock.familiarImages = ["familiar"]
        mock.stimulusImages = ["stimulus_1", "stimulus_2"]
        return mock
    }
}
