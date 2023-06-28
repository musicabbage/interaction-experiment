//
//  InstructionCoordinator.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/6/27.
//

import SwiftUI

struct InstructionCoordinator: View {
    let configurations: ConfigurationModel
    let experimentModel: ExperimentModel
    
//    let action: ExperimentFlowAction
    
    var body: some View {
        let viewModel = InstructionViewModel(configurations: configurations, experiment: experimentModel)
        InstructionView(viewModel: viewModel)
            .onTapGesture {
//                action.tapInstruction()
            }
    }
}
