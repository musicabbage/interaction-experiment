//
//  PreProcessFlowState.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/7/18.
//

import SwiftUI

enum PreProcessFlowLink: Hashable, Identifiable {
    case questionnaire
    
    var id: String { String(describing: self) }
}


class PreProcessFlowState: ObservableObject {
    @Published var path = NavigationPath()
    
    static var mock: StartExperimentFlowState {
        .init(path: .constant(.init()))
    }
}
