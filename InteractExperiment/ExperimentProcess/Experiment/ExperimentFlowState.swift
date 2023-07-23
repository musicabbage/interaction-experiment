//
//  ExperimentFlowState.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/7/2.
//

import SwiftUI

class ExperimentFlowState: ObservableObject {
    @Binding var path: NavigationPath
    
    init(path: Binding<NavigationPath>) {
        _path = .init(projectedValue: path)
    }
    
    static var mock: CreateConfigFlowState {
        CreateConfigFlowState(path: .constant(.init()))
    }
}
