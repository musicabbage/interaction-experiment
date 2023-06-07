//
//  ConfigurationModel.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/6/4.
//

import Foundation

struct ConfigurationModel {
    let id: String
    var name: String?
    var familiarImages: [String] = []
    var stimulusImages: [String] = []
    var folderURL: URL {
        FileManager.documentsDirectory.appending(path: id, directoryHint: .isDirectory)
    }
}
