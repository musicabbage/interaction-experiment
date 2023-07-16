//
//  ExperimentCoordinator.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/6/23.
//

import Foundation
import SwiftUI

struct ExperimentCoordinator: View {
    
    @StateObject var state: ExperimentFlowState
    private let viewModel: ExperimentViewModel
    
    init(navigationPath: Binding<NavigationPath>, configurations: ConfigurationModel, experiment: InteractLogModel) {
        _state = .init(wrappedValue: .init(path: navigationPath))
        self.viewModel = ExperimentViewModel(configuration: configurations, experiment: experiment)
    }
    
    var body: some View {
        ExperimentView(viewModel: viewModel)
            .onFinished(perform: { configurations, experiment in
                if experiment.phaseIndex >= configurations.phases.count {
                    state.path.append(ExperimentFlowLink.endTrial(configurations, experiment))
                } else {
                    state.path.append(ExperimentFlowLink.stimulus(configurations, experiment))
                }
            })
            .toolbar(.hidden, for: .navigationBar)
    }
}
