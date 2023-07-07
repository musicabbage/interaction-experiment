//
//  InteractLogModel.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/6/19.
//

import Foundation

struct InteractLogModel: Codable, Identifiable, Hashable {
    
    struct ActionModel: Codable, Hashable {
        enum Action: Codable, Hashable {
            case drawingEnabled
            case drawing(Bool, CGFloat, CGFloat)
            case familiarisation(Bool, String)
            case stimulus(Bool, String)
            
            var key: String {
                switch self {
                case .drawingEnabled:
                    return "DrawingEnabled"
                case let .drawing(isStart, _, _):
                    return "Button\( isStart ? "Down" : "Released" )"
                case let .familiarisation(isOn, name):
                    return "Familiarisation\( isOn ? "On" : "Off" )_\(name)"
                case let .stimulus(isOn, name):
                    return "Stimulus\( isOn ? "On" : "Off" )_\(name)"
                }
            }
        }
        
        let timestamp: Date
        let action: Action
        
        init(action: Action) {
            self.timestamp = .now
            self.action = action
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: InteractLogModel.ActionModel.CodingKeys.self)
            self.timestamp = try container.decode(Date.self, forKey: .timestamp)
            self.action = try container.decode(Action.self, forKey: .action)
        }
    }
    
    enum State: Codable, Hashable {
        case none, instruction, familiarisation, stimulus(Int)
    }
    
    /**
    > Name                 :Anonymous Participant
    > Experiment Start     :04/07/2023 - 16:29:49
     Stroke Colour        :0,0,0,255
     Background Colour    :255,255,255,255
     Stroke Width         :2.0
     Stimulus Files       :S1.png,S2.png,S3.png,S4.png,S5.png,S6.png,S7.png,S8.png
     Familiarisation File :P1.png
     Input Mask File      :
     Drawing Pad Size     :1260,600
    > Trial Number         :1
    > Trial Start          :04/07/2023 - 16:29:55
    > Trial End            :04/07/2023 - 16:30:00
     */
    let trialNumber: Int
    let id: String
    let configId: String
    let experimentStart: Date
    private(set) var participantId: String = ""
    private(set) var actions: [ActionModel] = []
    var trialStart: Date?
    var trialEnd: Date?
    
    var familiarisationInput: [[ActionModel]] = []
    var stimulusInput: [[ActionModel]] = []
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
        self.trialNumber = 1    //TODO: fixed trial number
        self.experimentStart = Date.now
        self.participantId = participantId
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.familiarisationInput = try container.decode([[ActionModel]].self, forKey: .familiarisationInput)
        self.stimulusInput = try container.decode([[ActionModel]].self, forKey: .stimulusInput)
        self.participantId = try container.decode(String.self, forKey: .participantId)
        self.id = try container.decode(String.self, forKey: .id)
        self.configId = try container.decode(String.self, forKey: .configId)
        self.stimulusIndex = try container.decode(Int.self, forKey: .stimulusIndex)
        self.experimentStart = try container.decode(Date.self, forKey: .experimentStart)
        self.trialNumber = try container.decode(Int.self, forKey: .trialNumber)
        self.trialStart = try container.decode(Date.self, forKey: .trialStart)
        self.trialEnd = try container.decode(Date.self, forKey: .trialEnd)
    }
    
    static func == (lhs: InteractLogModel, rhs: InteractLogModel) -> Bool {
        lhs.state == rhs.state && lhs.id == rhs.id
    }
    
    mutating func append(action: ActionModel) {
        actions.append(action)
    }
}

extension InteractLogModel {
    static var mock: InteractLogModel {
        InteractLogModel(participantId: "test_id", configId: "test_config_id")
    }
}
