//
//  InstructionView.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/6/19.
//

import SwiftUI

struct InstructionView: View {
    let instructionText: String
    
    var body: some View {
        Text(instructionText)
    }
}

struct InstructionView_Previews: PreviewProvider {
    static var previews: some View {
        InstructionView(instructionText: ConfigurationModel.mock.instruction)
    }
}
