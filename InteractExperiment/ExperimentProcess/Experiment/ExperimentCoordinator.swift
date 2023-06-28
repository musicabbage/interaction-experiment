//
//  ExperimentCoordinator.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/6/23.
//

import Foundation
import SwiftUI

struct ExperimentCoordinator: View {
    
    
    private let configurations: ConfigurationModel
    private let experiment: ExperimentModel
    
    init(navigationPath: Binding<NavigationPath>, configurations: ConfigurationModel, experiment: ExperimentModel) {
        self.configurations = configurations
        self.experiment = experiment
    }
    
    var body: some View {
        let viewModel = ExperimentViewModel(configuration: configurations, experiment: experiment)
        ExperimentView(viewModel: viewModel)
            .toolbar(.hidden, for: .navigationBar)
    }
}
