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
            return "Configurations"
        case .experiments:
            return "Experiments History"
        }
    }
}

struct RootView: View {
    @State private var selectItem: Menu?
    
    
    var body: some View {
        NavigationSplitView(sidebar: {
            List(Menu.allCases, selection: $selectItem, rowContent: { item in
                NavigationLink(item.title, value: item)
            })
        }, detail: {
            switch selectItem {
            case nil:
                Text("select from menu")
            case .configurations:
                ConfigurationsView()
            case .experiments:
                ExperimentsView()
            }
        })
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
