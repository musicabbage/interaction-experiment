//
//  FileManagerExtensions.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/6/5.
//

import Foundation

extension FileManager {
    static var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
