//
//  ExperimentViewModel.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/6/19.
//

import Foundation

protocol ExperimentViewModelProtocol: ObservableObject {
    var configuration: ConfigurationModel { get }
    var model: ExperimentModel { get }
    var viewState: ExperimentViewModel.ViewState { get }
}

class ExperimentViewModel: ExperimentViewModelProtocol {
    
    enum ViewState {
        case none
        case showParticipantId
    }
    
    private(set) var configuration: ConfigurationModel
    private(set) var model: ExperimentModel
    
    @Published private(set) var viewState: ViewState = .none
    
    init(configuration: ConfigurationModel, model: ExperimentModel) {
        self.configuration = configuration
        self.model = model
        
        if model.participantId.isEmpty {
            viewState = .showParticipantId
        }
    }
}

extension ExperimentViewModel {
    static var mock: ExperimentViewModel {
        ExperimentViewModel(configuration: .mock, model: .mock)
    }
}
