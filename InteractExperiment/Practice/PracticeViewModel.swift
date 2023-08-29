//
//  PracticeViewModel.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/7/20.
//

import Foundation
import Combine
import UIKit

class PracticeViewModel: ExperimentViewModelProtocol {
    
    enum Group {
        case A, B
        
        var configName: String {
            switch self {
            case .A: return "Practice_A"
            case .B: return "Practice_B"
            }
        }
    }
    
    enum PracticeStep {
        case tap, swipeUp, swipeRight, swipeRightTwoFingers, swipeLeft, nextPhase
    }
    
    enum ViewState {
        case showTutorial(PracticeStep)
        case hideTutorial
        case endTutorial(String)
    }
    
    private let viewStateSubject: PassthroughSubject<ExperimentViewModel.ViewState, Never> = .init()
    private let stepViewStateSubject: PassthroughSubject<ViewState, Never> = .init()
    private var step: PracticeStep = .tap
    private var cancellables: Set<AnyCancellable> = []
    
    let group: Group
    let configuration: ConfigurationModel
    let viewState: AnyPublisher<ExperimentViewModel.ViewState, Never>
    let stepViewState: AnyPublisher<ViewState, Never>
    private(set) var experiment: InteractLogModel
    var currentPhase: ConfigurationModel.PhaseModel? { configuration.phases.first }
    
    init(group: Group, experiment: InteractLogModel = .mock) {
        self.group = group
        self.configuration = PracticeViewModel.makePracticeConfiguration(group: group)
        self.experiment = experiment
        viewState = viewStateSubject.receive(on: DispatchQueue.main).eraseToAnyPublisher()
        stepViewState = stepViewStateSubject.receive(on: DispatchQueue.main).eraseToAnyPublisher()
        DispatchQueue.main.async {
            self.showStimulus(at:experiment.stimulusIndex, phase:experiment.phaseIndex)
        }
        setupBindings()
    }
    
    func showNextStimulus() {
         showStimulus(at: experiment.stimulusIndex + 1, phase: experiment.phaseIndex)
    }
    
    func appendSnapshot(image: UIImage) {
        
    }
    
    func appendLogAction(_ action: InteractLogModel.ActionModel.Action) {
        //use this function to detect what are participant doing👀
        guard experiment.phaseIndex == 0 else {
            if case let .stimulusDisplay(isShow, _, _) = action, isShow && experiment.stimulusIndex == 0 {
                stepViewStateSubject.send(.showTutorial(.tap))
            } else if group == .A {
                stepViewStateSubject.send(.hideTutorial)
            } else {
                stepViewStateSubject.send(.showTutorial(.swipeUp))
            }
            return
        }
        
        if case let .stimulusDisplay(isShow, _, _) = action,
           !isShow && experiment.stimulusIndex == configuration.phases.first!.images.count - 1 {
            //last image in the 1st phase
            stepViewStateSubject.send(.showTutorial(.nextPhase))
            return
        }
        
        switch (step, action) {
        case (_, .drawingEnabled):
            stepViewStateSubject.send(.showTutorial(.tap))
        case let (.tap, .stimulusDisplay(isShow, _, _)):
            if !isShow {
                stepViewStateSubject.send(.showTutorial(.swipeUp))
            }
        case let (.swipeUp, .stimulusDisplay(isShow, _, _)):
            if !isShow {
                stepViewStateSubject.send(.showTutorial(.swipeLeft))
            } else {
                stepViewStateSubject.send(.hideTutorial)
            }
        case let (.swipeLeft, .stimulusDisplay(isShow, _, _)):
            if isShow {
                stepViewStateSubject.send(.showTutorial(.swipeRight))
            } else {
                stepViewStateSubject.send(.hideTutorial)
            }
        case let (.swipeRight, .stimulusDisplay(isShow, _, _)):
            if !isShow {
                stepViewStateSubject.send(.showTutorial(.swipeRightTwoFingers))
            } else {
                stepViewStateSubject.send(.hideTutorial)
            }
        case let (_, .drawing(isStart, _)):
            if !isStart && group == .B {
                stepViewStateSubject.send(.showTutorial(.nextPhase))
            }
        default:
            stepViewStateSubject.send(.hideTutorial)
        }
    }
    
    func setDrawingPadSize(_ size: CGSize) {
        
    }
    
    func resetDrawingData() {
        
    }
    
    func appendDrawingData(_ drawing: DrawingModel) {
        
    }
    
    func collectAverageDrawingData() -> DrawingModel {
        return .init(timestamp: 0, point: .zero, force: 0, azimuth: 0, altitude: 0)
    }
}

private extension PracticeViewModel {
    func setupBindings() {
        stepViewState
            .sink { [unowned self] state in
                guard case let .showTutorial(newStep) = state else { return }
                self.step = newStep
            }
            .store(in: &cancellables)
    }
    
    func showStimulus(at index: Int, phase: Int) {
        experiment.phaseIndex = phase
        experiment.stimulusIndex = index
        let phaseItem = configuration.phases[experiment.phaseIndex]
        if experiment.stimulusIndex >= phaseItem.images.count,
           experiment.phaseIndex < configuration.phases.count - 1 {
            experiment.phaseIndex += 1
            experiment.stimulusIndex = 0
            viewStateSubject.send(.endPhase)
        } else {
            if let image = fetchImage(index: experiment.stimulusIndex, fromPhase: experiment.phaseIndex) {
                if (phase == 0) && (experiment.stimulusIndex >= phaseItem.images.count - 1) {
                    stepViewStateSubject.send(.endTutorial(group.endPracticeMessage))
                }
                viewStateSubject.send(.showNextStimulus(image))
            } else {
                if experiment.stimulusIndex >= phaseItem.images.count {
                    viewStateSubject.send(.error("End of practice"))
                } else {
                    viewStateSubject.send(.error("Fetch image failed"))
                }
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
    
    static func makePracticeConfiguration(group: Group) -> ConfigurationModel {
        
        
        func createPhases() -> [ConfigurationModel.PhaseModel] {
            var result: [ConfigurationModel.PhaseModel] = []
            
            switch group {
            case .A:
                //create phase 0
                var phase0 = ConfigurationModel.PhaseModel(name: "P_PHASE_0", showStimulusWhenDrawing: false)
                //make images, and then save to document folder
                let images0 = (1...3).compactMap { index -> String? in
                    let image: UIImage?
                    if index < 3 {
                        image = .init(systemName: "\(index).square")
                    } else {
                        let config = UIImage.SymbolConfiguration(paletteColors: [.darkGray, .tintColor])
                        image = UIImage(systemName: "\(index).square", withConfiguration: config)
                    }
                    
                    guard let image,
                          let scaledImage = image.resizeImageTo(size: .init(width: 350, height: 300)),
                          let imageData = scaledImage.pngData() else {
                        return nil
                    }
                    
                    do {
                        let name = "\(group.configName)_0_\(index).png"
                        try imageData.write(to: folderURL.appending(component: name))
                        return name
                    } catch {
                        print(error)
                        return nil
                    }
                }
                phase0.images = images0
                result.append(phase0)
                
                //phase 1 image
                if let image = UIImage(systemName: "3.square"),
                   let scaledImage = image.resizeImageTo(size: .init(width: 350, height: 300)),
                   let imageData = scaledImage.pngData() {
                    do {
                        let name = "\(group.configName)_1.png"
                        try imageData.write(to: folderURL.appending(component: name))
                        var phase1 = ConfigurationModel.PhaseModel(name: "P_PHASE_1", showStimulusWhenDrawing: false)
                        phase1.images = [name]
                        result.append(phase1)
                    } catch {
                        print(error)
                    }
                }
            case .B:
                result = [0, 1].compactMap { phaseIndex -> ConfigurationModel.PhaseModel? in
                    var image = UIImage(systemName: "door.french.closed")
                    if phaseIndex == 0 {
                        image = image?.withTintColor(.init(named: "Stimulus_line")!)
                    }
                    
                    guard let image,
                          let scaledImage = image.resizeImageTo(size: .init(width: 350, height: 300)),
                          let imageData = scaledImage.pngData() else {
                        return nil
                    }
                    
                    do {
                        let name = "\(group.configName)_\(phaseIndex).png"
                        try imageData.write(to: folderURL.appending(component: name))
                        var phase = ConfigurationModel.PhaseModel(name: "P_PHASE_\(phaseIndex)", showStimulusWhenDrawing: phaseIndex == 0)
                        phase.images = [name]
                        return phase
                    } catch {
                        print(error)
                        return nil
                    }
                }
            }
            return result
        }
        
        var configurations = ConfigurationModel(id: group.configName)
        
        var isDirectory = ObjCBool(false)
        let folderURL = configurations.folderURL
        print(folderURL)
        let fileExisted = FileManager.default.fileExists(atPath: folderURL.path(), isDirectory: &isDirectory)
        if !(fileExisted && isDirectory.boolValue) {
            try? FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
        } else if let configData = try? Data(contentsOf: configurations.configURL),
                  let configurations = try? JSONDecoder().decode(ConfigurationModel.self, from: configData) {
            return configurations
        }
        
        configurations.phases = createPhases()
        //encode configurations
        let configurationData = try? JSONEncoder().encode(configurations)
        try? configurationData!.write(to: configurations.configURL)
        
        return configurations
    }
}

extension PracticeViewModel.Group {
    
    var endPracticeMessage: String {
        switch self {
        case .A:
            return """
        When you see an image with a blue border, it indicates that this is the final image and the complete figure for this phase.\nIn the next phase, you will see the entire figure again and be asked to draw it from memory. If you would like to review the image again, simply swipe up using 2 fingers. Just like you did in this practice!
        """
        case .B:
            return """
        During this phase, please draw the figure by following the blue outline provided. Once you have completed the drawing, swipe left with 2 fingers to proceed to the next phase. \nIn the next phase, the figure will be presented again, and you will be asked to draw it from memory. If you want to review the image again, simply swipe up using 2 fingers.
        """
        }
    }
}

extension UIImage {
    
    func resizeImageTo(size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.draw(in: CGRect(origin: CGPoint.zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return resizedImage
    }
}
