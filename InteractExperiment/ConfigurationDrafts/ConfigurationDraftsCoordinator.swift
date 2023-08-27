//
//  ConfigurationDraftsCoordinator.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/8/27.
//

import SwiftUI

struct ConfigurationDraftsCoordinator: View {
    
    @ObservedObject var state: RootFlowState
    init(state: RootFlowState) {
        self.state = state
        print(FileManager.configsDirectory.absoluteString)
    }
    
    var body: some View {
        ConfigurationDraftsView(flowState: state, viewModel: ConfigurationDraftsViewModel())
    }
}

struct ConfigurationDraftsCoordinator_Previews: PreviewProvider {
    static var previews: some View {
        ConfigurationDraftsCoordinator(state: .init())
    }
}
