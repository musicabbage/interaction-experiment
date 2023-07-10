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
    
    func showNextStimulus()
    func appendSnapshot(image: UIImage)
    func appendFamiliarisationInputs(_ inputs: [LineAction])
    func appendStimulusInputs(_ inputs: [LineAction])
    func appendLogAction(_ action: InteractLogModel.ActionModel.Action)
}

class ExperimentViewModel: ExperimentViewModelProtocol {
    
    enum ViewState {
        case none
        case loading
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
        if experiment.state == .familiarisation {
            self.experiment.trialStart = Date.now
        }
        
        viewStateSubject = .init(.none)
        viewState = viewStateSubject.receive(on: DispatchQueue.main).eraseToAnyPublisher()
        if let image = fetchImage(index: experiment.stimulusIndex) {
            viewStateSubject.send(.showStimulus(image))
        } else {
            viewStateSubject.send(.error("cannot find the image..."))
        }
    }
    
    func showNextStimulus() {
        guard case .stimulus = experiment.state else {
            showStimulus()
            return
        }
        
        experiment.stimulusIndex += 1
        if experiment.stimulusIndex < configuration.stimulusImages.count {
            showStimulus()
        } else {
            do {
                try saveExperiment()
                viewStateSubject.send(.endTrial)
            } catch {
                viewStateSubject.send(.error("save experiment error...\n \(error.localizedDescription)"))
            }
        }
    }
    
    func appendLogAction(_ action: InteractLogModel.ActionModel.Action) {
        experiment.append(action: .init(action: action))
    }
    
    func appendFamiliarisationInputs(_ inputs: [LineAction]) {
        let actions = inputs.map { input in
            let action = InteractLogModel.ActionModel.Action.drawing(input.isStart, input.point.x, input.point.y)
            return InteractLogModel.ActionModel(action: action)
        }
        experiment.familiarisationInput.append(actions)
        actions.forEach { appendLogAction($0.action) }
    }
    
    func appendStimulusInputs(_ inputs: [LineAction]) {
        let actions = inputs.map { input in
            let action = InteractLogModel.ActionModel.Action.drawing(input.isStart, input.point.x, input.point.y)
            return InteractLogModel.ActionModel(action: action)
        }
        experiment.stimulusInput.append(actions)
        actions.forEach { appendLogAction($0.action) }
    }
    
    func appendSnapshot(image: UIImage) {
        do {
            let snapshot = try InteractLogModel.ImageModel(image: image)
            experiment.snapshots.append(snapshot)
        } catch {
            print(error)
        }
    }
}

private extension ExperimentViewModel {
    
    func showStimulus() {
        // TODO: append real InputData
        switch experiment.state {
        case .familiarisation:
            viewStateSubject.send(.endFamiliarisation)
        case let .stimulus(index):
            guard experiment.stimulusInput.count < configuration.stimulusImages.count else {
                endTrial()
                return
            }
            
            appendLogAction(.stimulus(true, configuration.stimulusImages[index]))
            experiment.stimulusInput.append(.init())
            if let image = fetchImage(index: index) {
                viewStateSubject.send(.showStimulus(image))
            } else {
                viewStateSubject.send(.error("fetch image failed"))
            }
        default:
            break
        }
    }
}

private extension ExperimentViewModel {
    func fetchImage(index: Int) -> UIImage? {
        var imageName: String?
        switch experiment.state {
        case .familiarisation:
            imageName = configuration.familiarImages.first
        case .stimulus:
            guard 0..<configuration.stimulusImages.count ~= index else { break }
            imageName = configuration.stimulusImages[index]
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
    
    func endTrial() {
        viewStateSubject.send(.loading)
        Task {
            do {
                experiment.trialEnd = Date.now
                try await writeLogFiles()
                viewStateSubject.send(.endTrial)
            } catch {
                viewStateSubject.send(.error("save experiment error...\n \(error.localizedDescription)"))
            }
        }
    }
    
    func writeLogFiles() async throws {
        let writer = InteractLogWriter()
        let folderURL = FileManager.experimentsDirectory.appending(path: experiment.id)
        var isDirectory = ObjCBool(false)
        
        let fileExisted = FileManager.default.fileExists(atPath: folderURL.path(), isDirectory: &isDirectory)
        if !(fileExisted && isDirectory.boolValue) {
            try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
        }
        
        //snapshots
        for snapshot in experiment.snapshots {
            guard let imageData = snapshot.image.jpegData(compressionQuality: 0.5) else {
                continue
            }
            let filename = String(describing: "\(Int(snapshot.timestamp)).png")
            try imageData.write(to: folderURL.appending(path: filename))
            experiment.finalSnapshotName = filename
        }
        
        
        //raw data
        let configurationData = try JSONEncoder().encode(experiment)
        try configurationData.write(to: folderURL.appendingPathComponent(InteractLogModel.filename))
        //log
        try writer.write(log: experiment, configurations: configuration, toFolder: folderURL)
    }
    
    func saveExperiment(toFolder folderURL: URL) throws {
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
