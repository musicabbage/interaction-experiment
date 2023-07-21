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
    
    let configuration: ConfigurationModel = PracticeViewModel.makePracticeConfiguration()
    let viewState: AnyPublisher<ExperimentViewModel.ViewState, Never>
    let stepViewState: AnyPublisher<ViewState, Never>
    private(set) var experiment: InteractLogModel
    var currentPhase: ConfigurationModel.PhaseModel? { configuration.phases.first }
    
    init(experiment: InteractLogModel = .mock) {
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
            } else {
                stepViewStateSubject.send(.hideTutorial)
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
        case (_, .drawing(_, _, _)):
            break
        default:
            stepViewStateSubject.send(.hideTutorial)
        }
    }
    
    func setDrawingPadSize(_ size: CGSize) {
        
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
           (0..<configuration.phases.count - 1) ~= experiment.phaseIndex {
            experiment.phaseIndex += 1
            experiment.stimulusIndex = 0
            viewStateSubject.send(.endPhase)
        } else {
            if let image = fetchImage(index: experiment.stimulusIndex, fromPhase: experiment.phaseIndex) {
                if (phase == 0) && (experiment.stimulusIndex >= phaseItem.images.count - 1) {
                    stepViewStateSubject.send(.endTutorial(endPracticeMessage))
                }
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
    
    static func makePracticeConfiguration() -> ConfigurationModel {
        
        var configurations = ConfigurationModel(id: "practice")
        
        var isDirectory = ObjCBool(false)
        let folderURL = configurations.folderURL
        let fileExisted = FileManager.default.fileExists(atPath: folderURL.path(), isDirectory: &isDirectory)
        if !(fileExisted && isDirectory.boolValue) {
            try? FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
        } else if let configData = try? Data(contentsOf: configurations.configURL),
                  let configurations = try? JSONDecoder().decode(ConfigurationModel.self, from: configData) {
            return configurations
        }
        
        print(folderURL)
        let phase1 = ConfigurationModel.PhaseModel(name: "P_PHASE_0", showStimulusWhenDrawing: false)
        let phase2 = ConfigurationModel.PhaseModel(name: "P_PHASE_1", showStimulusWhenDrawing: false)
        configurations.phases = [phase1, phase2]
        let images = (1...3).map { index in
            let name = "PRACTICE_0_\(index)"
            if index < 3 {
                return ImageInfo(image: .init(systemName: "\(index).square")!, imageName: name)
            } else {
                let config = UIImage.SymbolConfiguration(paletteColors: [.darkGray, .tintColor])
                let lastImage = UIImage(systemName: "\(index).square", withConfiguration: config)!
                return ImageInfo(image: lastImage, imageName: "PRACTICE_3")
            }
        }
        let phaseImages = [phase1.name: images]
        
        for phaseName in phaseImages.keys {
            guard let phaseImages = phaseImages[phaseName],
                  let phaseIndex = configurations.phases.firstIndex(where: { $0.name == phaseName }) else { continue }
            
            for image in phaseImages {
                
                guard let scaledImage = image.image.resizeImageTo(size: .init(width: 350, height: 300)),
                        let imageData = scaledImage.pngData() else {
                    continue
                }
                
                try? imageData.write(to: folderURL.appending(component: image.imageName))
            }
            configurations.phases[phaseIndex].images = phaseImages.map(\.imageName)
        }
        
        //phase 2 image
        let image = ImageInfo(image: UIImage(systemName: "3.square")!, imageName: "PRACTICE_1")
        if let scaledImage = image.image.resizeImageTo(size: .init(width: 350, height: 300)),
           let imageData = scaledImage.pngData() {
            try? imageData.write(to: folderURL.appending(component: image.imageName))
            let lastIndex = configurations.phases.count - 1
            configurations.phases[lastIndex].images = [image.imageName]
        }
   
        //encode configurations
        let configurationData = try? JSONEncoder().encode(configurations)
        try? configurationData!.write(to: configurations.configURL)
        
        return configurations
    }
    
    var endPracticeMessage: String {
        """
        When you see an image with a blue border, it indicates that this is the final image and the complete figure for this phase.\nIn the next phase, you will see the entire figure again and be asked to draw it from memory. If you would like to review the image once more, simply swipe up using two fingers.
        """
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
