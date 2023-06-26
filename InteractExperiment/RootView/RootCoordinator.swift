//
//  RootCoordinator.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/6/24.
//

import SwiftUI

struct RootCoordinator: View {
    @ObservedObject var state: RootFlowState = .init()
    
    var body: some View {
        NavigationSplitView {
            List(Menu.allCases) { item in
                NavigationLink(item.title, value: item)
            }
        } detail: {
            NavigationStack(path: $state.path) {
                RootView(flowState: state)
                    .navigationDestination(for: RootFlowLink.self, destination: navigationDestination)
                    .sheet(item: $state.presentedItem, content: presentContent)
                    .fullScreenCover(item: $state.coverItem, content: coverContent)
            }
        }
    }
}

private extension RootCoordinator {
    @ViewBuilder
    private func navigationDestination(process: RootFlowLink) -> some View {
        switch process {
        case let .startExperiment(configPath):
            if let data = try? Data(contentsOf: URL(filePath: configPath)),
               let configurations = try? JSONDecoder().decode(ConfigurationModel.self, from: data) {
                let viewModel = ExperimentViewModel(configuration: configurations, model: ExperimentModel())
                StartExperimentView(viewModel: viewModel)
            } else {
                Text("instruction get config error")
            }
        default:
            Text("not implemented process")
        }
    }
    
    @ViewBuilder
    private func presentContent(item: RootFlowLink) -> some View {
        switch item {
        case .createConfig:
            CreateConfigurationCoordinator(navigationPath: $state.path)
        default:
            Text("undefined present content")
        }
    }

    @ViewBuilder
    private func coverContent(item: RootFlowLink) -> some View {
        Text("undefined cover content")
    }
}
