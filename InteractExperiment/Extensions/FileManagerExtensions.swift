//
//  FileManagerExtensions.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/6/5.
//

import Foundation

extension FileManager {
    static var configsDirectory: URL {
        .documentsDirectory.appendingPathComponent("configs")
    }
    
    static var experimentsDirectory: URL {
        .documentsDirectory.appendingPathComponent("experiments")
    }
}
