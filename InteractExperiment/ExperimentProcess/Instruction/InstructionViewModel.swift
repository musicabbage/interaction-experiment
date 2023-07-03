//
//  InstructionViewModel.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/6/27.
//

import Combine

protocol InstructionViewModelProtocol {
    var configurations: ConfigurationModel { get }
    var experiment: InteractLogModel { get }
}

class InstructionViewModel: InstructionViewModelProtocol {
    
    private(set) var configurations: ConfigurationModel
    private(set) var experiment: InteractLogModel
    
    init(configurations: ConfigurationModel, experiment: InteractLogModel) {
        self.configurations = configurations
        self.experiment = experiment
    }
}
