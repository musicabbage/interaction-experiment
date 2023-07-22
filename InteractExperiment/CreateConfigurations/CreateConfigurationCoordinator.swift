//
//  CreateConfigurationCoordinator.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/6/21.
//

import Foundation
import SwiftUI

struct CreateConfigurationCoordinator: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject var state: CreateConfigFlowState
    
    private let viewModel: CreateConfigurationViewModel = .init()

    init(navigationPath: Binding<NavigationPath>) {
        _state = .init(wrappedValue: .init(path: navigationPath))
    }
    
    var body: some View {
        CreateConfigurationView(flowState: state,
                                viewModel: viewModel,
                                phases: .defaultExperimentImagesModels)
        .interactiveDismissDisabled()
            .onChange(of: state.dismiss) { newValue in
                guard newValue == true else { return }
                dismiss()
            }
            .onDisappear {
                guard viewModel.currentViewState == .savedAndContinue else { return }
                let configPath = viewModel.configurations.configURL.path()
                state.path.append(RootFlowLink.configCreated(configPath))
            }
    }
}

private extension [ExperimentImagesModel] {
    static var defaultExperimentImagesModels: [ExperimentImagesModel] {
        [ExperimentImagesModel(type: .familiarisation),
         ExperimentImagesModel(type: .stimulus)]
    }
}
