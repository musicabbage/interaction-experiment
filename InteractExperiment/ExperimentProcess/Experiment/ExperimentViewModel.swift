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
    var currentPhase: ConfigurationModel.PhaseModel? { get }
    var viewState: AnyPublisher<ExperimentViewModel.ViewState, Never> { get }
    
    func showNextStimulus()
    func appendSnapshot(image: UIImage)
    func appendFamiliarisationInputs(_ inputs: [InteractLogModel.ActionModel])
    func appendStimulusInputs(_ inputs: [InteractLogModel.ActionModel])
    func appendLogAction(_ action: InteractLogModel.ActionModel.Action)
    func setDrawingPadSize(_ size: CGSize)
}

class ExperimentViewModel: ExperimentViewModelProtocol {
    
    enum ViewState {
        case none
        case loading
        case showNextStimulus(UIImage)
        case endPhase
        case endTrial
        case error(String)
    }
    
    private let viewStateSubject: CurrentValueSubject<ViewState, Never>
    private(set) var configuration: ConfigurationModel
    private(set) var experiment: InteractLogModel
    
    let viewState: AnyPublisher<ViewState, Never>
    var currentPhase: ConfigurationModel.PhaseModel? {
        guard experiment.phaseIndex < configuration.phases.count else {
            return nil
        }
        return configuration.phases[experiment.phaseIndex]
        
    }
    
    init(configuration: ConfigurationModel, experiment: InteractLogModel) {
        self.configuration = configuration
        self.experiment = experiment
        if experiment.phaseIndex == 0 && experiment.stimulusIndex == 0 {
            self.experiment.trialStart = Date.now
        }
        
        viewStateSubject = .init(.none)
        viewState = viewStateSubject.receive(on: DispatchQueue.main).eraseToAnyPublisher()
        Task {
            var phaseIndex = experiment.phaseIndex
            var stimulusIndex = experiment.stimulusIndex
            while phaseIndex < configuration.phases.count &&
                    configuration.phases[phaseIndex].images.isEmpty {
                phaseIndex += 1
                stimulusIndex = 0
            }
            showStimulus(at: stimulusIndex, phase: phaseIndex)
        }
    }
    
    func showNextStimulus() {
        showStimulus(at: experiment.stimulusIndex + 1, phase: experiment.phaseIndex)
    }
    
    func appendLogAction(_ action: InteractLogModel.ActionModel.Action) {
        experiment.append(action: .init(action: action))
    }
    
    func appendFamiliarisationInputs(_ inputs: [InteractLogModel.ActionModel]) {
        experiment.familiarisationInput.append(inputs)
    }
    
    func appendStimulusInputs(_ inputs: [InteractLogModel.ActionModel]) {
        experiment.stimulusInput.append(inputs)
    }
    
    func appendSnapshot(image: UIImage) {
        do {
            let snapshot = try InteractLogModel.ImageModel(image: image)
            experiment.snapshots.append(snapshot)
        } catch {
            print(error)
        }
    }
    
    func setDrawingPadSize(_ size: CGSize) {
        experiment.drawingPadSize = size
    }
}

private extension ExperimentViewModel {
    func showStimulus(at index: Int, phase: Int) {
        experiment.phaseIndex = phase
        experiment.stimulusIndex = index
        if experiment.phaseIndex >= configuration.phases.count {
            endTrial()
        } else if experiment.stimulusIndex >= configuration.phases[experiment.phaseIndex].images.count {
            experiment.stimulusIndex = 0
            experiment.phaseIndex += 1
            if experiment.phaseIndex >= configuration.phases.count {
                endTrial()
            } else {
                viewStateSubject.send(.endPhase)
            }
        } else {
            if let image = fetchImage(index: experiment.stimulusIndex, fromPhase: experiment.phaseIndex) {
                viewStateSubject.send(.showNextStimulus(image))
            } else {
                viewStateSubject.send(.error("fetch image failed"))
            }
        }
    }
    
    func fetchImage(index: Int, fromPhase phase: Int) -> UIImage? {
        guard phase < configuration.phases.count,
              index < configuration.phases[phase].images.count else {
            return nil
        }
        
        let imageName = configuration.phases[phase].images[index]
        guard let imageData = try? Data(contentsOf: configuration.folderURL.appending(path: imageName)) else {
            return nil
        }
        
        return UIImage(data: imageData)
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
}

extension ExperimentViewModel {
    static var mock: ExperimentViewModel {
        ExperimentViewModel(configuration: .mock, experiment: .mock)
    }
}
