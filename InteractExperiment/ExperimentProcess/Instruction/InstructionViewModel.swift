//
//  InstructionViewModel.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/6/27.
//

import Combine

protocol InstructionViewModelProtocol {
    var configurations: ConfigurationModel { get }
    var experiment: ExperimentModel { get }
}

class InstructionViewModel: InstructionViewModelProtocol {
    
    private(set) var configurations: ConfigurationModel
    private(set) var experiment: ExperimentModel
    
    init(configurations: ConfigurationModel, experiment: ExperimentModel) {
        self.configurations = configurations
        self.experiment = experiment
    }
}
