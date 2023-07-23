//
//  StartExperimentCoordinator.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/6/28.
//

import SwiftUI

struct StartExperimentCoordinator: View {
    @StateObject var state: StartExperimentFlowState
    @State private var presentPreprocess: Bool = false
    @State private var experiment: InteractLogModel? = nil
    
    private let configurations: ConfigurationModel
    
    
    init(navigationPath: Binding<NavigationPath>, configurations: ConfigurationModel) {
        _state = .init(wrappedValue: .init(path: navigationPath))
        self.configurations = configurations
    }
    
    var body: some View {
        ZStack {
            EmptyView()
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            state.showParticipantId = true
        }
        .sheet(item: $experiment, content: preprocessViews)
        .alert("Participant ID", isPresented: $state.showParticipantId, actions: alertView)
    }
}

private extension StartExperimentCoordinator {
    @ViewBuilder
    func alertView() -> some View {
        ParticipantIdAlertView(participantId: configurations.defaultParticipantId)
          .onConfirmParticipantId { participantId in
              experiment = .init(participantId: participantId, configId: configurations.id)
          }
    }
    
    @ViewBuilder
    func preprocessViews(_ experiment: InteractLogModel) -> some View {
        PreProcessCoordinator(configurations: configurations, experiment: experiment)
            .onDisappear {
                state.path.append(RootFlowLink.startExperiment(configurations, experiment))
            }
    }
}

