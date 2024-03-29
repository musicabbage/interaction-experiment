//
//  RootFlowState.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/6/25.
//

import SwiftUI

enum RootFlowLink: Hashable, Identifiable {
    case createConfig
    case editConfig(ConfigurationModel)
    case configCreated(String) //config path
    case startExperiment(ConfigurationModel, InteractLogModel) //configurations, InteractLogModel
    case exportExperiment(URL)
    
    var id: String { String(describing: self) }
}

class RootFlowState: ObservableObject {
    @Published var path = NavigationPath()
    @Published var presentedItem: RootFlowLink?
    @Published var coverItem: RootFlowLink?
}
