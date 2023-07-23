//
//  EndExperimentView.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/7/3.
//

import SwiftUI

struct EndExperimentView: View {
    let viewModel: EndExperimentViewModelProtocol
    var closeClosure: () -> Void = { }
    
    var body: some View {
        VStack {
            Text("The experiment is finished, thanks for taking part.")
                .font(.title)
                .padding(26)
            Button("close", action: closeClosure)
                .padding(.init(top: 8, leading: 8, bottom: 8, trailing: 8))
                .foregroundColor(.white)
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerSize: .init(width: 6, height: 6)))
        }
    }
}

extension EndExperimentView {
    func onClosed(perform action: @escaping() -> Void) -> Self {
        var copy = self
        copy.closeClosure = action
        return copy
    }
}

struct EndExperimentView_Previews: PreviewProvider {
    static var previews: some View {
        EndExperimentView(viewModel: EndExperimentViewModel.mock)
    }
}
