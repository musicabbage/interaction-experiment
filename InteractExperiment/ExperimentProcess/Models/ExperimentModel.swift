//
//  ExperimentModel.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/6/19.
//

import Foundation

struct ExperimentModel: Codable, Identifiable, Hashable {
    
    enum State: Codable {
        case none, instruction, familiarisation, stimulus(Int)
    }
    
    private(set) var participantId: String = ""
    var id: String { String(describing: self) }
    
    var state: State {
        //TODO: check return state
        if participantId.isEmpty {
            return .instruction
        } else {
            return .familiarisation
        }
    }
}

extension ExperimentModel {
    static var mock: ExperimentModel {
        ExperimentModel(participantId: "test_id")
    }
}
