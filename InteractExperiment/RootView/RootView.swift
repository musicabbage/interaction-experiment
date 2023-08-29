//
//  RootView.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/5/25.
//

import SwiftUI

enum Menu: Int, CaseIterable, Identifiable {
    case previousExperiments
    case drafts
    case practiceA
    case practiceB
    
    var id: Int { rawValue }
    var title: String {
        switch self {
        case .previousExperiments:
            return "Previous Experiments"
        case .drafts:
            return "Drafts"
        case .practiceA:
            return "Playground A"
        case .practiceB:
            return "Playground B"
        }
    }
}

struct RootView: View {

    @State private var selectItem: Menu?
    @State private var showCreateSheet: Bool = false
    @ObservedObject var state: RootFlowState
    
    init(flowState: RootFlowState) {
        self.state = flowState
    }
    
    var body: some View {
        PreviousExperimentsView(viewModel: PreviousExperimentsViewModel())
            .onUseConfiguration(perform: { configPath in
                state.path.append(RootFlowLink.configCreated(configPath))
            })
            .onExportExperiment(perform: { zipUrl in
                state.presentedItem = .exportExperiment(zipUrl)
            })
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(flowState: .init())
    }
}
