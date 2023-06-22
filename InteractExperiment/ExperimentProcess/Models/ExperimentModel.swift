//
//  ExperimentModel.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/6/19.
//

import Foundation

struct ExperimentModel {
    var participantId: String = ""
}

extension ExperimentModel {
    static var mock: ExperimentModel {
        ExperimentModel(participantId: "test_id")
    }
}
