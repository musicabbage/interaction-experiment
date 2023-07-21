//
//  PracticeCoordinator.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/7/21.
//

import SwiftUI

struct PracticeCoordinator: View {
    
    @Binding var navigationPath: NavigationPath
    let experiment: InteractLogModel
    
    init(navigationPath: Binding<NavigationPath>, experiment: InteractLogModel = .mock) {
        _navigationPath = .init(projectedValue: navigationPath)
        self.experiment = experiment
    }
    
    var body: some View {
        PracticeView(viewModel: .init(experiment: experiment))
                .onFinished { configurations, experiment in
                    navigationPath.append(PracticeFlowLink.nextPhase(configurations, experiment))
                }
    }
}
