//
//  RootCoordinator.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/6/24.
//

import SwiftUI

struct RootCoordinator: View {
    @State var columnVisibility: NavigationSplitViewVisibility = .automatic
    @StateObject var state: RootFlowState = .init()
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List(Menu.allCases) { item in
                NavigationLink(item.title, value: item)
            }
        } detail: {
            NavigationStack(path: $state.path) {
                RootView(flowState: state)
                    .navigationDestination(for: RootFlowLink.self, destination: rootNavDestination)
                    .navigationDestination(for: ExperimentFlowLink.self, destination: experimentNavDestination)
                    .sheet(item: $state.presentedItem, content: presentContent)
                    .fullScreenCover(item: $state.coverItem, content: coverContent)
            }
        }
    }
}

private extension RootCoordinator {
    @ViewBuilder
    private func rootNavDestination(process: RootFlowLink) -> some View {
        switch process {
        case let .configCreated(configPath):
            if let data = try? Data(contentsOf: URL(filePath: configPath)),
               let configurations = try? JSONDecoder().decode(ConfigurationModel.self, from: data) {
                StartExperimentCoordinator(navigationPath: $state.path, configurations: configurations)
                    .onAppear {
                        columnVisibility = .detailOnly
                    }
            } else {
                Text("instruction get config error")
            }
        case let .startExperiment(configurations, participantId):
            let experiment = InteractLogModel(participantId: participantId, configId: configurations.id)
            InstructionCoordinator(state: .init(path: $state.path), configurations: configurations, experimentModel: experiment)
        default:
            Text("not implemented process")
        }
    }
    
    @ViewBuilder
    private func experimentNavDestination(process: ExperimentFlowLink) -> some View {
        switch process {
        case let .familiarisation(configurations, experiment),
            let .stimulus(configurations, experiment):
            ExperimentCoordinator(navigationPath: $state.path, configurations: configurations, experiment: experiment)
        case let .endTrial(configurations, experiment):
            EndExperimentCoordinator(navigationPath: $state.path, configurations: configurations, experiment: experiment)
                .onDisappear {
                    columnVisibility = .automatic
                }
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
