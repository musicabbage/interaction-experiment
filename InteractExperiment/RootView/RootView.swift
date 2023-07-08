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
    @ObservedObject var flowState: RootFlowState
    
    private let createConfigViewModel = CreateConfigurationViewModel()
    
    init(flowState: RootFlowState) {
        self.flowState = flowState
    }
    
    var body: some View {
        Button("Create a new experiment", action: {
            flowState.presentedItem = .createConfig
        })
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(flowState: .init())
    }
}
