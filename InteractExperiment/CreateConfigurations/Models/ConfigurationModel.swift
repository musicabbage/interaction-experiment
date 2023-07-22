//
//  ConfigurationModel.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/6/4.
//

import Foundation

struct ConfigurationModel: Codable, Identifiable, Hashable {

    struct PhaseModel: Codable, Identifiable, Hashable {
        let name: String
        let showStimulusWhenDrawing: Bool
        var id: String
        var images: [String] = []
        
        init(id: String = UUID().uuidString, name: String, showStimulusWhenDrawing: Bool = true) {
            self.id = id
            self.name = name
            self.showStimulusWhenDrawing = showStimulusWhenDrawing
        }
    }
    
    static let configFilename: String = "config"
    
    let id: String
    var instruction: String
    var isDraft: Bool = false
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
        self.instruction = instruction ?? ConfigurationModel.defaultInstruction
        self.phases = phases
    }
}

extension ConfigurationModel {
    static var mock: ConfigurationModel {
        var mock = ConfigurationModel()
        mock.phases = [.mock, .mock]
        return mock
    }
    
    static var defaultInstruction: String {
        """
        When you are ready to start, tap the screen to begin the drawing experiment.\n
        Please use the Apple Pencil for drawing and your finger to show/hide images.\n
        """
    }
}

extension ConfigurationModel.PhaseModel {
    static var mock: ConfigurationModel.PhaseModel {
        var mock = ConfigurationModel.PhaseModel(name: "mock")
        mock.images = ["stimulus_1", "stimulus_2"]
        return mock
    }
}
