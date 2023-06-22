//
//  RootView.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/5/25.
//

import SwiftUI

enum Menu: Int, CaseIterable, Identifiable {
    case configurations
    case experiments
    
    var id: Int { rawValue }
    var title: String {
        switch self {
        case .configurations:
            return "New Experiments"
        case .experiments:
            return "Previous Experiments"
        }
    }
}

struct RootView: View {
    private let createConfigurationCoordinator: CreateConfigurationCoordinator
    @State private var selectItem: Menu?
    @State private var showCreateSheet: Bool = false
    @StateObject private var createConfigViewModel = CreateConfigurationViewModel()
    @StateObject private var navigationModel: NavigationModel
    
    init() {
        let navigationModel = NavigationModel()
        createConfigurationCoordinator = CreateConfigurationCoordinator(navigation: navigationModel)
        _navigationModel = .init(wrappedValue: navigationModel)
    }

    var body: some View {
        NavigationSplitView(columnVisibility: $navigationModel.columnVisibility,
                            sidebar: {
            List(Menu.allCases, selection: $selectItem, rowContent: { item in
                NavigationLink(item.title, value: item)
            })
        }, detail: {            
            switch selectItem {
            case nil:
                NavigationStack(path: $navigationModel.processPath) {
                    Button("Create a new experiment", action: {
                        showCreateSheet.toggle()
                    })
                    .sheet(isPresented: $showCreateSheet, content: {
                        createConfigurationCoordinator
                            .startCreatingConfiguration()
                    })
                }
                .navigationDestination(for: ExperimentProcess.self) { process in
                    if case let .instruction(configPath) = process,
                       let data = try? Data(contentsOf: URL(filePath: configPath)),
                       let configurations = try? JSONDecoder().decode(ConfigurationModel.self, from: data) {
                        StartExperimentView(viewModel: ExperimentViewModel(configuration: configurations, model: ExperimentModel()))
                    } else {
                        Text("Navigation error page")
                    }
                }
            case .configurations:
                ConfigurationsView()
            case .experiments:
                ExperimentsView()
            }
        })
#if os(macOS)
        .frame(minWidth: 800, minHeight: 600)
#endif
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
