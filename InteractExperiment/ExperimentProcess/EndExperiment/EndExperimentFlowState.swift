//
//  EndExperimentFlowState.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/7/3.
//

import SwiftUI

class EndExperimentFlowState: ObservableObject {
    @Binding var path: NavigationPath
    
    init(path: Binding<NavigationPath>) {
        _path = .init(projectedValue: path)
    }
    
}
