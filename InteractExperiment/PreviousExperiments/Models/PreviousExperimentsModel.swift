//
//  PreviousExperimentsModel.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/7/8.
//

import Foundation

struct PreviousExperimentsModel: Identifiable {
    
    let id: String
    let date: Date
    let participantId: String
    let familiarisationsURLs: [URL]
    let stimulusURLs: [URL]
    
    init(experiment: InteractLogModel, configurations: ConfigurationModel) {
        id = experiment.id
        date = .now
        participantId = experiment.participantId
        familiarisationsURLs = configurations.familiarImages.map { configurations.folderURL.appendingPathComponent($0) }
        stimulusURLs = configurations.stimulusImages.map { configurations.folderURL.appendingPathComponent($0) }
    }
}

extension PreviousExperimentsModel {
    static var mock: PreviousExperimentsModel {
        .init(experiment: .mock, configurations: .mock)
    }
}
