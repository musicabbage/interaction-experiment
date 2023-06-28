//
//  StartExperimentCoordinator.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/6/28.
//

import SwiftUI

struct StartExperimentCoordinator: View {
    @StateObject var state: StartExperimentFlowState
    
    private let configurations: ConfigurationModel
    
    init(navigationPath: Binding<NavigationPath>, configurations: ConfigurationModel) {
        _state = .init(wrappedValue: .init(path: navigationPath))
        self.configurations = configurations
    }
    
    var body: some View {
        ZStack {
            EmptyView()
        }
        .onAppear { state.showParticipantId = true }
        .alert("Participant ID", isPresented: $state.showParticipantId, actions: alertView)
    }
}

private extension StartExperimentCoordinator {
    @ViewBuilder
    func alertView() -> some View {
        ParticipantIdAlertView()
          .onConfirmParticipantId { participantId in
              state.path.append(RootFlowLink.startExperiment(configurations, participantId))
          }
    }
}
