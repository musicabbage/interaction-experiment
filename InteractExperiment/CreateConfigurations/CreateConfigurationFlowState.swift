//
//  CreateConfigurationFlowState.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/6/26.
//

import SwiftUI

class CreateConfigFlowState: ObservableObject {
    @Binding var path: NavigationPath
    @Published var dismiss: Bool?
    
    init(path: Binding<NavigationPath>) {
        _path = .init(projectedValue: path)
    }
    
    static var mock: CreateConfigFlowState {
        CreateConfigFlowState(path: .constant(.init()))
    }
}
