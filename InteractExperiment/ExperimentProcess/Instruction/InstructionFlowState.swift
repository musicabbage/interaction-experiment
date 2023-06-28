//
//  InstructionFlowState.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/6/27.
//

import SwiftUI

class InstructionFlowState: ObservableObject {
    @Binding var path: NavigationPath
    
    init(path: Binding<NavigationPath>) {
        _path = .init(projectedValue: path)
    }
    
    static var mock: InstructionFlowState { .init(path: .constant(.init())) }
}
