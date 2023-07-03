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
            .onFinished(perform: {
                switch viewModel.experiment.state {
                case .instruction, .familiarisation:
                    let configurations = viewModel.configuration
                    let experiment = viewModel.experiment
                    state.path.append(ExperimentFlowLink.stimulus(configurations, experiment))
                case .stimulus:
                    //TODO: show end message
                    break
                default:
                    break
                }
            })
            .toolbar(.hidden, for: .navigationBar)
    }
}
