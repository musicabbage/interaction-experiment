//
//  RootCoordinator.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/6/24.
//

import SwiftUI

struct RootCoordinator: View {
    @StateObject private var state: RootFlowState = .init()
    @State private var columnVisibility: NavigationSplitViewVisibility = .automatic
    @State private var selectedMenu: Menu? = .drafts
    @State private var practiceANavPath: NavigationPath = .init()
    @State private var practiceBNavPath: NavigationPath = .init()
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List(Menu.allCases, selection: $selectedMenu) { item in
                NavigationLink(item.title, value: item)
            }
        } detail: {
            switch selectedMenu {
            case .newExperiment:
                NavigationStack(path: $state.path) {
                    Button("start a new experiment") {
                        state.presentedItem = .createConfig
                    }
                    .actionButtonStyle()
                    .padding([.bottom], 64)
                    .navigationDestination(for: RootFlowLink.self, destination: rootNavDestination)
                    .navigationDestination(for: ExperimentFlowLink.self, destination: experimentNavDestination)
                }
            case .drafts:
                NavigationStack(path: $state.path) {                    
                    ConfigurationDraftsCoordinator(state: state)
                        .navigationDestination(for: RootFlowLink.self, destination: rootNavDestination)
                        .navigationDestination(for: ExperimentFlowLink.self, destination: experimentNavDestination)
                        .fullScreenCover(item: $state.coverItem, content: coverContent)
                }
            case .previousExperiments:
                NavigationStack(path: $state.path) {
                    RootView(flowState: state)
                        .navigationDestination(for: RootFlowLink.self, destination: rootNavDestination)
                        .navigationDestination(for: ExperimentFlowLink.self, destination: experimentNavDestination)
                        .fullScreenCover(item: $state.coverItem, content: coverContent)
                }
            case .practiceA:
                NavigationStack(path: $practiceANavPath) {
                    PracticeCoordinator(navigationPath: $practiceANavPath, group: .A)
                        .navigationDestination(for: PracticeFlowLink.self, destination: practiceNavDestination)
                }
            case .practiceB:
                NavigationStack(path: $practiceBNavPath) {
                    PracticeCoordinator(navigationPath: $practiceBNavPath, group: .B)
                        .navigationDestination(for: PracticeFlowLink.self, destination: practiceNavDestination)
                }
            default:
                EmptyView()
            }
        }
        .sheet(item: $state.presentedItem, content: presentContent)
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
        case let .startExperiment(configurations, experiment):
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
    private func practiceNavDestination(process: PracticeFlowLink) -> some View {
        switch process {
        case let .nextPhase(_, experiment):
            let group: PracticeViewModel.Group = (selectedMenu == .practiceA) ? .A : .B
            PracticeCoordinator(navigationPath: $state.path, group: group, experiment: experiment)
        }
    }
    
    @ViewBuilder
    private func presentContent(item: RootFlowLink) -> some View {
        switch item {
        case .createConfig:
            CreateConfigurationCoordinator(navigationPath: $state.path)
        case let .editConfig(configurationModel):
            CreateConfigurationCoordinator(navigationPath: $state.path, configuration: configurationModel)
        case let .exportExperiment(zipURL):
            ActivityViewController(activityItems: [zipURL])
        default:
            Text("undefined present content")
        }
    }

    @ViewBuilder
    private func coverContent(item: RootFlowLink) -> some View {
        Text("undefined cover content")
    }
}

struct RootCoordinator_Previews: PreviewProvider {
    static var previews: some View {
        RootCoordinator()
    }
}
