//
//  CreateConfigurationCoordinator.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/6/21.
//

import Foundation
import SwiftUI

class CreateConfigFlowState: ObservableObject {
    @Binding var path: NavigationPath
    @Published var dismiss: Bool?
    
    init(path: Binding<NavigationPath>, dismiss: Bool? = nil) {
        _path = .init(projectedValue: path)
        self.dismiss = dismiss
    }
    
    static var mock: CreateConfigFlowState {
        CreateConfigFlowState(path: .constant(.init()))
    }
}

struct CreateConfigurationCoordinator: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject var state: CreateConfigFlowState
    
    private let viewModel: CreateConfigurationViewModel = .init()

    init(navigationPath: Binding<NavigationPath>) {
        _state = .init(wrappedValue: .init(path: navigationPath))
    }
    
    var body: some View {
        CreateConfigurationView(flowState: state, viewModel: viewModel)
            .onChange(of: state.dismiss) { newValue in
                guard newValue == true else { return }
                dismiss()
            }
            .onDisappear {
                guard viewModel.viewState == .savedAndContinue else { return }
                let configPath = viewModel.configurations.configURL.path()
                state.path.append(RootFlowLink.startExperiment(configPath))
            }
    }
}