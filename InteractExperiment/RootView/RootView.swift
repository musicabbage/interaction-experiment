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
    
    
    init(flowState: RootFlowState) {
        self.flowState = flowState
    }
    
    var body: some View {
        PreviousExperimentsView(viewModel: PreviousExperimentsViewModel())
            .onUseExperiment(perform: { experimentId in
                print(experimentId)
            })
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button("start a new experiment") {
                        flowState.presentedItem = .createConfig
                    }
                    .actionButtonStyle()
                    .padding([.bottom], 64)
                }
            }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(flowState: .init())
    }
}
