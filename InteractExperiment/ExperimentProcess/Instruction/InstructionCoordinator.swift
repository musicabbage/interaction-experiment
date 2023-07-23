//
//  InstructionCoordinator.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/6/27.
//

import SwiftUI

struct InstructionCoordinator: View {
    @StateObject var state: InstructionFlowState
    
    let configurations: ConfigurationModel
    let experimentModel: InteractLogModel
    
    var body: some View {
        let viewModel = InstructionViewModel(configurations: configurations, experiment: experimentModel)
        InstructionView(viewModel: viewModel)
            .toolbar(.hidden, for: .navigationBar)
            .onTapGesture {
                state.path.append(ExperimentFlowLink.familiarisation(configurations, experimentModel))
            }
    }
}
