//
//  EndExperimentViewModel.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/7/3.
//

import Foundation

protocol EndExperimentViewModelProtocol {
    var configurations: ConfigurationModel { get }
    var experiment: InteractLogModel { get }
}

class EndExperimentViewModel: EndExperimentViewModelProtocol {
    
    private(set) var configurations: ConfigurationModel
    private(set) var experiment: InteractLogModel
    
    init(configurations: ConfigurationModel, experiment: InteractLogModel) {
        self.configurations = configurations
        self.experiment = experiment
    }
}

extension EndExperimentViewModel {
    static var mock: EndExperimentViewModel {
        EndExperimentViewModel(configurations: .mock, experiment: .mock)
    }
}
