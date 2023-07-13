//
//  InteractLogModel.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/6/19.
//

import Foundation

struct InteractLogModel: Codable, Identifiable, Hashable {
    
    enum State: Codable, Hashable {
        case none, instruction, familiarisation, stimulus(Int)
    }
    
    private(set) var participantId: String = ""
    let id: String
    let configId: String
    var familiarisationInput: [InputDataModel] = []
    var stimulusInput: [InputDataModel] = []
    var stimulusIndex: Int = 0
    
    var state: State {
        //TODO: check return state
        if participantId.isEmpty {
            return .instruction
        } else if familiarisationInput.isEmpty {
            return .familiarisation
        } else {
            return .stimulus(stimulusIndex)
        }
    }
    
    init(participantId: String, configId: String) {
        self.id = UUID().uuidString
        self.configId = configId
        self.participantId = participantId
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.participantId = try container.decode(String.self, forKey: .participantId)
        self.id = try container.decode(String.self, forKey: .id)
        self.configId = try container.decode(String.self, forKey: .configId)
        self.familiarisationInput = try container.decode([InputDataModel].self, forKey: .familiarisationInput)
        self.stimulusInput = try container.decode([InputDataModel].self, forKey: .stimulusInput)
        self.stimulusIndex = try container.decode(Int.self, forKey: .stimulusIndex)
    }
    
    static func == (lhs: InteractLogModel, rhs: InteractLogModel) -> Bool {
        lhs.state == rhs.state && lhs.id == rhs.id
    }
}

extension InteractLogModel {
    static var mock: InteractLogModel {
        InteractLogModel(participantId: "test_id", configId: "test_config_id")
    }
}
