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
    @State private var selectItem: Menu?
    @State private var showCreateSheet: Bool = false
    
    var body: some View {
        NavigationSplitView(sidebar: {
            List(Menu.allCases, selection: $selectItem, rowContent: { item in
                NavigationLink(item.title, value: item)
            })
        }, detail: {
            switch selectItem {
            case nil:
                Button("Create a new experiment", action: {
                    showCreateSheet.toggle()
                })
                .sheet(isPresented: $showCreateSheet, content: {
                    CreateConfigurationView(viewModel: CreateConfigurationViewModel())
                })
                
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
