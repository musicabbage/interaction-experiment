//
//  ConfigurationModel.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/6/4.
//

import Foundation

struct ConfigurationModel: Codable, Identifiable, Hashable {

    struct PhaseModel: Codable, Identifiable, Hashable {
        var id: String
        let name: String
        var images: [String] = []
        
        init(id: String = UUID().uuidString, name: String) {
            self.id = id
            self.name = name
        }
    }
    
    static let configFilename: String = "config"
    
    let id: String
    var isDraft: Bool = false
    var instruction: String
    var phases: [PhaseModel] = []
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
         phases: [PhaseModel] = []) {
        self.id = id
        self.isDraft = isDraft
        self.instruction = instruction ?? """
When you are ready to start, press 'N' to open the recording pad.\n
When you are finished drawing, press ESC to close the recording pad.
"""
        self.phases = phases
    }
}

extension ConfigurationModel {
    static var mock: ConfigurationModel {
        var mock = ConfigurationModel()
        mock.phases = [.mock, .mock]
        return mock
    }
}

extension ConfigurationModel.PhaseModel {
    static var mock: ConfigurationModel.PhaseModel {
        var mock = ConfigurationModel.PhaseModel(name: "mock")
        mock.images = ["stimulus_1", "stimulus_2"]
        return mock
    }
}
