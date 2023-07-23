//
//  PracticeFlowState.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/7/21.
//

import Foundation

enum PracticeFlowLink: Hashable, Identifiable {
    case nextPhase(ConfigurationModel, InteractLogModel) //configurations, InteractLogModel
    
    var id: String { String(describing: self) }
}
