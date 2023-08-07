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
    var gestureInstruction: String { get }
    var cautions: String { get }
}

class InstructionViewModel: InstructionViewModelProtocol {
    
    private(set) var configurations: ConfigurationModel
    private(set) var experiment: InteractLogModel

    init(configurations: ConfigurationModel, experiment: InteractLogModel) {
        self.configurations = configurations
        self.experiment = experiment
    }
}

extension InstructionViewModel {
    var gestureInstruction: String {
        """
        ● Show the image again → Swipe UP with TWO fingers ✌️
        ● Hide the image → Tap with ONE finger 👆
        ● Show the previous image → Swipe RIGHT with TWO fingers ✌️
        ● Show the next image → Swipe LEFT with TWO fingers ✌️
        """
    }
    
    var cautions: String {
        "CAUTIONS: You cannot modify or erase your drawing.\nPlease draw carefully with every stroke."
    }
}
