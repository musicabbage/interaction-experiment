//
//  InstructionView.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/6/19.
//

import SwiftUI

struct InstructionView: View {
    let viewModel: InstructionViewModelProtocol
    
    var body: some View {
        VStack {
            Text("Hi, \(viewModel.experiment.participantId)")
                .font(.title)
                .padding(12)
            Text(viewModel.configurations.instruction)
                .font(.title)
            Text(viewModel.gestureInstruction)
                .font(.title)
                .lineSpacing(12)
                .foregroundColor(.text.sectionTitle)
                .padding(22)
            Text(viewModel.cautions)
                .font(.title)
                .padding(22)
        }
    }
}

struct InstructionView_Previews: PreviewProvider {
    static var previews: some View {
        InstructionView(viewModel: InstructionViewModel(configurations: .mock, experiment: .mock))
    }
}
