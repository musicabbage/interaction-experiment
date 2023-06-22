//
//  StartExperimentView.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/6/19.
//

import SwiftUI

struct StartExperimentView<ViewModel>: View where ViewModel: ExperimentViewModelProtocol {
    @State private var showParticipantIdAlert: Bool = false
    @ObservedObject private var viewModel: ViewModel
    @Environment(\.isPresented) private var isPresented
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            if !showParticipantIdAlert {
                Text(viewModel.configuration.instruction)
            }
        }
        .alert("ParticipantId", isPresented: $showParticipantIdAlert) { ParticipantIdAlertView() }
        .onAppear {
            showParticipantIdAlert = true
        }
        .onChange(of: viewModel.viewState) { viewState in
            switch viewState {
            case .showParticipantId:
                showParticipantIdAlert = true
            default:
                break
            }
        }
    }
    
}

struct StartExperimentView_Previews: PreviewProvider {
    static var previews: some View {
        StartExperimentView(viewModel: ExperimentViewModel(configuration: .mock, model: .mock))
    }
}
