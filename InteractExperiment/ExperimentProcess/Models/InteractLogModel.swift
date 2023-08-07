//
//  InteractLogModel.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/6/19.
//

import Foundation
import UIKit

extension CGSize : Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(width)
    hasher.combine(height)
  }
}

struct DrawingModel: Codable, Hashable {
    let timestamp: TimeInterval
    let point: CGPoint
    let force: CGFloat
    let azimuth: CGFloat
    let altitude: CGFloat
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(timestamp)
    }
}

struct InteractLogModel: Codable, Identifiable, Hashable {
    static let filename: String = "InteractLog.json"
    
    struct ActionModel: Codable, Hashable {
        enum Action: Codable, Hashable {
            case drawingEnabled
            case drawing(Bool, DrawingModel)
            case pencilDrawing(DrawingModel)
            case familiarisation(Bool, String)
            case stimulus(Bool, String)
            case stimulusDisplay(isShow: Bool, phaseName: String, fileName: String)
            
            var key: String {
                switch self {
                case .drawingEnabled:
                    return "DrawingEnabled"
                case let .drawing(isStart, _):
                    return "Button\( isStart ? "Down" : "Released" )"
                case let .familiarisation(isOn, name):
                    return "Familiarisation\( isOn ? "On" : "Off" )_\(name)"
                case let .stimulus(isOn, name):
                    return "Stimulus\( isOn ? "On" : "Off" )_\(name)"
                case let .stimulusDisplay(isShow: isOn, phaseName: phase, fileName: file):
                    return "\(phase)\( isOn ? "On" : "Off" )_\(file)"
                case .pencilDrawing:
                    return "Pencil"
                }
            }
        }
        
        let timestamp: TimeInterval
        let action: Action
        
        init(action: Action) {
            self.timestamp = Date.timestamp
            self.action = action
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: InteractLogModel.ActionModel.CodingKeys.self)
            self.timestamp = try container.decode(TimeInterval.self, forKey: .timestamp)
            self.action = try container.decode(Action.self, forKey: .action)
        }
    }
    
    struct ImageModel: Codable, Hashable {
        let timestamp: TimeInterval
        let image: UIImage
        
        enum Keys: String, CodingKey {
            case timestamp, image
        }
        
        init(image: UIImage) throws {
            self.timestamp = Date.timestamp
            self.image = image
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: Keys.self)
            self.timestamp = try container.decode(TimeInterval.self, forKey: .timestamp)
            if let imageData = try? container.decode(Data.self, forKey: .image),
               let image = UIImage(data: imageData) {
                self.image = image
            } else {
                throw NSError(domain: "decode image for ImageModel error", code: 100001)
            }
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: Keys.self)
            try container.encode(timestamp, forKey: .timestamp)
            if let imageData = image.pngData() {
                try container.encode(imageData, forKey: .image)
            } else {
                throw NSError(domain: "encode image for ImageModel error", code: 100002)
            }
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
    let appVersion: String
    private(set) var participantId: String = ""
    private(set) var actions: [ActionModel] = []
    var drawingPadSize: CGSize = .zero
    var trialStart: Date?
    var trialEnd: Date?
    
    var stimulusIndex: Int = 0
    var phaseIndex: Int = 0
    
    var finalSnapshotName: String = ""
    var snapshots: [ImageModel] = []
    var folderURL: URL {
        FileManager.experimentsDirectory.appending(path: id)
    }
    
    init(participantId: String, configId: String) {
        self.id = UUID().uuidString
        self.configId = configId
        self.trialNumber = 1    //TODO: fixed trial number
        self.experimentStart = Date.now
        self.participantId = participantId
        self.appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.participantId = try container.decode(String.self, forKey: .participantId)
        self.id = try container.decode(String.self, forKey: .id)
        self.configId = try container.decode(String.self, forKey: .configId)
        if let appVersion = try? container.decode(String.self, forKey: .appVersion) {
            self.appVersion = appVersion
        } else {
            self.appVersion = ""
        }
        self.stimulusIndex = try container.decode(Int.self, forKey: .stimulusIndex)
        self.phaseIndex = try container.decode(Int.self, forKey: .phaseIndex)
        self.experimentStart = try container.decode(Date.self, forKey: .experimentStart)
        self.trialNumber = try container.decode(Int.self, forKey: .trialNumber)
        self.trialStart = try container.decode(Date.self, forKey: .trialStart)
        self.trialEnd = try container.decode(Date.self, forKey: .trialEnd)
        self.snapshots = try container.decode([ImageModel].self, forKey: .snapshots)
        self.finalSnapshotName = try container.decode(String.self, forKey: .finalSnapshotName)
        self.drawingPadSize = try container.decode(CGSize.self, forKey: .drawingPadSize)
    }
    
    static func == (lhs: InteractLogModel, rhs: InteractLogModel) -> Bool {
        lhs.phaseIndex == rhs.phaseIndex && lhs.stimulusIndex == rhs.stimulusIndex && lhs.id == rhs.id
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
