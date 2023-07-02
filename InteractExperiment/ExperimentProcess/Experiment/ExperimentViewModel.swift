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
    
}

class ExperimentViewModel: ExperimentViewModelProtocol {
    
    enum ViewState {
        case none
        case displayImage(UIImage)
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
            viewStateSubject.send(.displayImage(image))
        } else {
            viewStateSubject.send(.error("cannot find the image..."))
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
}

extension ExperimentViewModel {
    static var mock: ExperimentViewModel {
        ExperimentViewModel(configuration: .mock, experiment: .mock)
    }
}
