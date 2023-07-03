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
    var familiarisationInput: [InputDataModel] = []
    var stimulusInput: [InputDataModel] = []
    
    var state: State {
        //TODO: check return state
        if participantId.isEmpty {
            return .instruction
        } else if familiarisationInput.isEmpty {
            return .familiarisation
        } else {
            return .stimulus(stimulusInput.count)
        }
    }
    
    init(participantId: String) {
        self.id = UUID().uuidString
        self.participantId = participantId
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.familiarisationInput = try container.decode([InputDataModel].self, forKey: .familiarisationInput)
        self.participantId = try container.decode(String.self, forKey: .participantId)
        self.id = try container.decode(String.self, forKey: .id)
    }
    
    static func == (lhs: InteractLogModel, rhs: InteractLogModel) -> Bool {
        lhs.state == rhs.state && lhs.id == rhs.id
    }
}

extension InteractLogModel {
    static var mock: InteractLogModel {
        InteractLogModel(participantId: "test_id")
    }
}
