//
//  PreviousExperimentsModel.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/7/8.
//

import Foundation
import UIKit

struct PreviousExperimentsModel: Identifiable {
    
    let id: String
    let date: Date?
    let participantId: String
    let configurationURL: URL
    let folderURL: URL
    let phases: [[String: [UIImage]]]
    
    init(experiment: InteractLogModel, configurations: ConfigurationModel) {
        id = experiment.id
        date = experiment.trialStart
        participantId = experiment.participantId
        configurationURL = configurations.configURL
        folderURL = experiment.folderURL
        phases = configurations.phases.reduce(into: [[String: [UIImage]]](), { partialResult, phase in
            let images = phase.images.reduce(into: [UIImage]()) { images, fileName in
                do {
                    let imageData = try Data(contentsOf: configurations.folderURL.appendingPathComponent(fileName))
                    if let image = UIImage(data: imageData) {
                        images.append(image)
                    }
                } catch {
                    print("get phase image error:")
                    print(error)
                }
            }
            partialResult.append([phase.name: images])
        })
    }
}

extension PreviousExperimentsModel {
    init(phases: [ConfigurationModel.PhaseModel]) {
        self.id = "mock_id"
        self.date = .now
        self.participantId = "mock participant"
        self.configurationURL = URL(filePath: "")
        self.phases = phases.reduce(into: [[String: [UIImage]]](), { partialResult, phase in
            let images = phase.images.reduce(into: [UIImage]()) { images, imageName in
                if let image = UIImage(named: imageName) {
                    images.append(image)
                } else  {
                    print("get phase image error")
                }
            }
            partialResult.append([phase.name: images])
        })
        self.folderURL = URL(fileURLWithPath: "")
    }
    
    static var mock: PreviousExperimentsModel {
        .init(phases: [.mock])
    }
}
