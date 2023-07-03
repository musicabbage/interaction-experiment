//
//  EndExperimentCoordinator.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/7/3.
//

import SwiftUI

struct EndExperimentCoordinator: View {
    @StateObject var state: InstructionFlowState
    
    let configurations: ConfigurationModel
    let experimentModel: InteractLogModel
    
    init(navigationPath: Binding<NavigationPath>, configurations: ConfigurationModel, experiment: InteractLogModel) {
        _state = .init(wrappedValue: .init(path: navigationPath))
        self.configurations = configurations
        self.experimentModel = experiment
    }
    
    var body: some View {
        let viewModel = EndExperimentViewModel(configurations: configurations, experiment: experimentModel)
        EndExperimentView(viewModel: viewModel)
            .onClosed {
                state.path.removeLast(state.path.count)
            }
            .toolbar(.hidden, for: .navigationBar)
            
    }
}
