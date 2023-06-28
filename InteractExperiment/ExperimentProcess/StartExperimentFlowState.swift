//
//  StartExperimentFlowState.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/6/28.
//

import SwiftUI

enum ExperimentFlowLink: Hashable, Identifiable {
    case familiarisation(ConfigurationModel, ExperimentModel)
    
    var id: String { String(describing: self) }
}

class StartExperimentFlowState: ObservableObject {
    @Binding var path: NavigationPath
    @Binding var columnVisibility: NavigationSplitViewVisibility
    @Published var showParticipantId: Bool = false
    
    init(path: Binding<NavigationPath>, columnVisibility: Binding<NavigationSplitViewVisibility>) {
        _path = .init(projectedValue: path)
        _columnVisibility = .init(projectedValue: columnVisibility)
    }
    
    static var mock: StartExperimentFlowState {
        .init(path: .constant(.init()), columnVisibility: .constant(.automatic))
    }
}
