//
//  PreProcessCoordinator.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/7/18.
//

import SwiftUI

struct PreProcessCoordinator: View {
    
    @StateObject var state: PreProcessFlowState = .init()
    
    private let configurations: ConfigurationModel
    private let experiment: InteractLogModel
 
    init(configurations: ConfigurationModel, experiment: InteractLogModel) {
        self.configurations = configurations
        self.experiment = experiment
    }
    
    var body: some View {
        NavigationStack(path: $state.path) {
            let viewModel = PreProcessViewModel(configurations: configurations, experiment: experiment)
            ConsentFormView(viewModel: viewModel)
                .onFinished(perform: {
                    state.path.append(PreProcessFlowLink.questionnaire(viewModel.questionnaireURL))
                })
                .navigationDestination(for: PreProcessFlowLink.self, destination: preProcessDestination)
        }
        .interactiveDismissDisabled()
    }
}

private extension PreProcessCoordinator {
    @ViewBuilder
    private func preProcessDestination(process: PreProcessFlowLink) -> some View {
        switch process {
        case let .questionnaire(url):
            WebView(url: url)
        }
    }
}
