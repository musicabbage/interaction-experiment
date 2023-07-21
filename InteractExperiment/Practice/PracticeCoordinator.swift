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
    let group: PracticeViewModel.Group
    
    init(navigationPath: Binding<NavigationPath>, group: PracticeViewModel.Group, experiment: InteractLogModel = .mock) {
        _navigationPath = .init(projectedValue: navigationPath)
        self.experiment = experiment
        self.group = group
    }
    
    var body: some View {
        PracticeView(viewModel: .init(group: group, experiment: experiment))
                .onFinished { configurations, experiment in
                    navigationPath.append(PracticeFlowLink.nextPhase(configurations, experiment))
                }
    }
}
