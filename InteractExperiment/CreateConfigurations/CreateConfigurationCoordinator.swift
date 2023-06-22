//
//  CreateConfigurationCoordinator.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/6/21.
//

import Foundation
import SwiftUI

class CreateConfigurationCoordinator {
    private let navigationModel: NavigationModel
    private var viewModel: (any CreateConfigurationViewModelProtocol)!
    
    init(navigation: NavigationModel) {
        self.navigationModel = navigation
    }
    
    @MainActor func startCreatingConfiguration() -> some View {
        let viewModel = CreateConfigurationViewModel()
        let createConfigurationView = CreateConfigurationView(viewModel: viewModel)
            .onDisappear { [unowned self] in
                guard viewModel.viewState == .savedAndContinue else { return }
                let configPath = viewModel.configurations.configURL.path()
                self.navigationModel.processPath.append(.instruction(configPath))
                self.navigationModel.columnVisibility = .detailOnly
            }
        self.viewModel = viewModel
        return createConfigurationView
    }
}

private extension CreateConfigurationView {
    func setupViewModelBindings() {
        
    }
}
