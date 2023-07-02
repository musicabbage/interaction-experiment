//
//  ExperimentCoordinator.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/6/23.
//

import Foundation
import SwiftUI

struct ExperimentCoordinator: View {
    
    private let viewModel: ExperimentViewModel
    
    init(navigationPath: Binding<NavigationPath>, configurations: ConfigurationModel, experiment: InteractLogModel) {
        self.viewModel = ExperimentViewModel(configuration: configurations, experiment: experiment)
    }
    
    var body: some View {
        ExperimentView(viewModel: viewModel)
            .toolbar(.hidden, for: .navigationBar)
    }
}
