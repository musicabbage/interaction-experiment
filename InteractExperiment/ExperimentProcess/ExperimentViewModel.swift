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
    
    func updateParticipantId(_ participantId: String)
}

class ExperimentViewModel: ExperimentViewModelProtocol {
    
    enum ViewState {
        case none
        case showParticipantId
        case instruction
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
    
    func updateParticipantId(_ participantId: String) {
        model.participantId = participantId
        viewState = .instruction
    }
}

extension ExperimentViewModel {
    static var mock: ExperimentViewModel {
        ExperimentViewModel(configuration: .mock, model: .mock)
    }
}
