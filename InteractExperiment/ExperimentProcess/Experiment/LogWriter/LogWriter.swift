//
//  LogWriter.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/7/4.
//

import Foundation

protocol LogWriterProtocol {
    func write(log: InteractLogModel, configurations: ConfigurationModel, toFolder folderPath: URL) throws
}
