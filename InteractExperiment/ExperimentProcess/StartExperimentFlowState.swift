//
//  StartExperimentFlowState.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/6/28.
//

import SwiftUI

enum ExperimentFlowLink: Hashable, Identifiable {
    case familiarisation(ConfigurationModel, InteractLogModel)
    case stimulus(ConfigurationModel, InteractLogModel)
    case endTrial(ConfigurationModel, InteractLogModel)
    
    var id: String { String(describing: self) }
}

class StartExperimentFlowState: ObservableObject {
    @Binding var path: NavigationPath
    @Published var showParticipantId: Bool = false
    
    init(path: Binding<NavigationPath>) {
        _path = .init(projectedValue: path)
    }
    
    static var mock: StartExperimentFlowState {
        .init(path: .constant(.init()))
    }
}
