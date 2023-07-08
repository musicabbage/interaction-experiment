//
//  ExperimentViewModel.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/6/19.
//

import Foundation
import Combine
import UIKit

protocol ExperimentViewModelProtocol {
    var configuration: ConfigurationModel { get }
    var experiment: InteractLogModel { get }
    var viewState: AnyPublisher<ExperimentViewModel.ViewState, Never> { get }
    
    func showStimulus()
}

class ExperimentViewModel: ExperimentViewModelProtocol {
    
    enum ViewState {
        case none
        case showStimulus(UIImage)
        case endFamiliarisation
        case endTrial
        case error(String)
    }
    
    private let viewStateSubject: CurrentValueSubject<ViewState, Never>
    private(set) var configuration: ConfigurationModel
    private(set) var experiment: InteractLogModel
    
    let viewState: AnyPublisher<ViewState, Never>
    
    init(configuration: ConfigurationModel, experiment: InteractLogModel) {
        self.configuration = configuration
        self.experiment = experiment
        
        viewStateSubject = .init(.none)
        viewState = viewStateSubject.eraseToAnyPublisher()
        if let image = fetchImage() {
            viewStateSubject.send(.showStimulus(image))
        } else {
            viewStateSubject.send(.error("cannot find the image..."))
        }
    }
    
    func showStimulus() {
        
        // TODO: append real InputData
        switch experiment.state {
        case .familiarisation:
            experiment.familiarisationInput.append(.init())
            viewStateSubject.send(.endFamiliarisation)
        case let .stimulus(index):
            guard experiment.stimulusInput.count < configuration.stimulusImages.count else {
                do {
                    try saveExperiment()
                    viewStateSubject.send(.endTrial)
                } catch {
                    viewStateSubject.send(.error("save experiment error...\n \(error.localizedDescription)"))
                }
                return
            }
            
            experiment.stimulusInput.append(.init())
            if let image = fetchImage() {
                viewStateSubject.send(.showStimulus(image))
            } else if index >= configuration.stimulusImages.count {
                viewStateSubject.send(.endTrial)
            } else {
                viewStateSubject.send(.error("fetch image failed"))
            }
        default:
            break
        }
    }
}

private extension ExperimentViewModel {
    func fetchImage() -> UIImage? {
        var imageName: String?
        switch experiment.state {
        case .familiarisation:
            imageName = configuration.familiarImages.first
        case let .stimulus(index):
            if index < configuration.stimulusImages.count {
                imageName = configuration.stimulusImages[index]
            }
        default:
            break
        }
        
        guard let imageName,
              let imageData = try? Data(contentsOf: configuration.folderURL.appending(path: imageName)) else {
            return nil
        }
        
        return UIImage(data: imageData)
    }
    
    func saveExperiment() throws {
        var isDirectory = ObjCBool(false)
        let folderURL = FileManager.experimentsDirectory
        let fileExisted = FileManager.default.fileExists(atPath: folderURL.path(), isDirectory: &isDirectory)
        if !(fileExisted && isDirectory.boolValue) {
            try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
        }
        
        //encode configurations
        let configurationData = try JSONEncoder().encode(experiment)
        try configurationData.write(to: folderURL.appendingPathComponent(experiment.id))
    }
}

extension ExperimentViewModel {
    static var mock: ExperimentViewModel {
        ExperimentViewModel(configuration: .mock, experiment: .mock)
    }
}
