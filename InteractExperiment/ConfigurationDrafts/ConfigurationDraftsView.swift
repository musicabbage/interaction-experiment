//
//  ConfigurationDraftsView.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/8/27.
//

import SwiftUI

struct ConfigurationDraftsView: View {
    @State private var configurations: [ConfigurationModel] = []
    
    private let viewModel: ConfigurationDraftsViewModelProtocol
    private let flowState: RootFlowState
    
    init(flowState: RootFlowState, viewModel: ConfigurationDraftsViewModelProtocol) {
        self.flowState = flowState
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            if configurations.count == 0 {
                Image(systemName: "list.dash.header.rectangle")
                    .resizable()
                    .scaledToFill()
                    .foregroundColor(Color.button.lightgray)
                    .frame(width: 88, height: 88, alignment: .center)
                    .padding(32)
                Button("start a new experiment") {
                    flowState.presentedItem = .createConfig
                }
                .actionButtonStyle()
            } else {
                ScrollView(.vertical) {
                    LazyVStack(alignment: .leading, spacing: 15) {
                        ForEach(configurations) { configuration in
                            ConfigurationItemView(configuration: configuration)
                                .onTapAction { action in
                                    switch action {
                                    case .use:
                                        break
                                    case .edit:
                                        flowState.presentedItem = .editConfig(configuration)
                                    }
                                }
                        }
                    }
                    .padding(22)
                }
            }
        }
        .onReceive(viewModel.viewState) { viewState in
            switch viewState {
            case let .loadDrafts(drafts):
                self.configurations = drafts
            }
        }
    }
}

struct ConfigurationDraftsView_Previews: PreviewProvider {
    static var previews: some View {
        ConfigurationDraftsView(flowState: .init(), viewModel: ConfigurationDraftsViewModel.mock)
    }
}
