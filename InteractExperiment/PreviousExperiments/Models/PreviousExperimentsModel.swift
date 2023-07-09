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
    let date: Date
    let participantId: String
    let configurationURL: URL
    let familiarisationsImages: [UIImage]
    let stimulusImages: [UIImage]
    
    init(experiment: InteractLogModel, configurations: ConfigurationModel) {
        id = experiment.id
        date = .now
        participantId = experiment.participantId
        configurationURL = configurations.configURL
        familiarisationsImages = configurations.familiarImages.reduce(into: [UIImage](), { partialResult, fileName in
            do {
                let imageData = try Data(contentsOf: configurations.folderURL.appendingPathComponent(fileName))
                if let image = UIImage(data: imageData) {
                    partialResult.append(image)
                }
            } catch {
                print("get familiarisation image error:")
                print(error)
            }
        })
        
        stimulusImages = configurations.stimulusImages.reduce(into: [UIImage](), { partialResult, fileName in
            do {
                let imageData = try Data(contentsOf: configurations.folderURL.appendingPathComponent(fileName))
                if let image = UIImage(data: imageData) {
                    partialResult.append(image)
                }
            } catch {
                print("get familiarisation image error:")
                print(error)
            }
        })
    }
}

extension PreviousExperimentsModel {
    
    init(familiarisationsImages: [UIImage], stimulusImages: [UIImage]) {
        self.id = "mock_id"
        self.date = .now
        self.participantId = "mock participant"
        self.configurationURL = URL(filePath: "")
        self.familiarisationsImages = familiarisationsImages
        self.stimulusImages = stimulusImages
    }
    
    static var mock: PreviousExperimentsModel {
        .init(familiarisationsImages: [.mockFamiliarisationImage], stimulusImages: [.mockFamiliarisationImage])
    }
}
