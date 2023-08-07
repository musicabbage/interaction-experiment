//
//  ExperimentViewModel.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/6/19.
//

import Foundation
import Combine
import UIKit
import Accelerate

protocol ExperimentViewModelProtocol {
    var configuration: ConfigurationModel { get }
    var experiment: InteractLogModel { get }
    var currentPhase: ConfigurationModel.PhaseModel? { get }
    var viewState: AnyPublisher<ExperimentViewModel.ViewState, Never> { get }
    
    func showNextStimulus()
    func appendSnapshot(image: UIImage)
    func appendLogAction(_ action: InteractLogModel.ActionModel.Action)
    func setDrawingPadSize(_ size: CGSize)
    //calculate drawing data from apple pencil
    func resetDrawingData()
    func appendDrawingData(_ drawing: DrawingModel)
    func collectAverageDrawingData() -> DrawingModel
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
    private var drawingData: [DrawingModel] = []
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
    
    func resetDrawingData() {
        drawingData = []
    }
    
    func appendDrawingData(_ drawing: DrawingModel) {
        drawingData.append(drawing)
    }
    
    func collectAverageDrawingData() -> DrawingModel {
        /**
         let timestamp: TimeInterval
         let point: CGPoint
         let force: CGFloat
         let azimuth: CGFloat
         let altitude: CGFloat
         */
        let forceData = drawingData.map { Double($0.force) }
        let meanForce = vDSP.mean(forceData)
        
        let azimuthData = drawingData.map { Double($0.azimuth) }
        let meanAzimuth = vDSP.mean(azimuthData)
        
        let altitudeData = drawingData.map { Double($0.altitude) }
        let meanAltitude = vDSP.mean(altitudeData)
        
        let pointXData = drawingData.map { Double($0.point.x) }
        let meanPointX = vDSP.mean(pointXData)
        let pointYData = drawingData.map { Double($0.point.y) }
        let meanPointY = vDSP.mean(pointYData)
        let meanPoint = CGPoint(x: meanPointX, y: meanPointY)
        return .init(timestamp: Date.now.timeIntervalSince1970,
                     point: meanPoint,
                     force: meanForce,
                     azimuth: meanAzimuth,
                     altitude: meanAzimuth)
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
            } else if !configuration.phases[experiment.phaseIndex].images.isEmpty {
                viewStateSubject.send(.endPhase)
            } else {
                showStimulus(at: 0, phase: experiment.phaseIndex + 1)
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
        let folderURL = experiment.folderURL
        var isDirectory = ObjCBool(false)
        let fileExisted = FileManager.default.fileExists(atPath: folderURL.path(), isDirectory: &isDirectory)
        if !(fileExisted && isDirectory.boolValue) {
            try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
        }
        
        //snapshots
        for snapshot in experiment.snapshots {
            guard let imageData = snapshot.image.jpegData(compressionQuality: 0.75) else {
                continue
            }
            let filename = String(describing: "\(Int(snapshot.timestamp)).jpeg")
            try imageData.write(to: folderURL.appending(path: filename))
            experiment.finalSnapshotName = filename
        }
        experiment.snapshots = []
        
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
