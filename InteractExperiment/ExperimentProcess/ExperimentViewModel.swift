//
//  ExperimentViewModel.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/6/19.
//

import Foundation
import Combine

protocol ExperimentViewModelProtocol: ObservableObject {
    var configuration: ConfigurationModel { get }
    var model: ExperimentModel { get }
    var viewState: AnyPublisher<ExperimentViewModel.ViewState, Never> { get }
    
    func updateParticipantId(_ participantId: String)
}

class ExperimentViewModel: ExperimentViewModelProtocol {
    
    enum ViewState {
        case none
        case showParticipantId
        case instruction
    }
    
    private let viewStateSubject: PassthroughSubject<ViewState, Never>
    private(set) var configuration: ConfigurationModel
    private(set) var model: ExperimentModel
    
    let viewState: AnyPublisher<ViewState, Never>
    
    init(configuration: ConfigurationModel, model: ExperimentModel) {
        self.configuration = configuration
        self.model = model
        
        viewStateSubject = PassthroughSubject<ViewState, Never>()
        viewState = viewStateSubject.eraseToAnyPublisher()
    }
    
    func updateParticipantId(_ participantId: String) {
        model.participantId = participantId
        viewStateSubject.send(.instruction)
    }
}

extension ExperimentViewModel {
    static var mock: ExperimentViewModel {
        ExperimentViewModel(configuration: .mock, model: .mock)
    }
}
