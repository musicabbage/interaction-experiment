//
//  PreviousExperimentsView.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/7/7.
//

import SwiftUI

struct PreviousExperimentsView: View {
    
    @State private var experiments: [PreviousExperimentsModel] = []
    
    private let viewModel: PreviousExperimentsViewModelProtocol
    var useClosure: ((String) -> Void) = { _ in }
    var deleteClosure: ((String) -> Void) = { _ in }
    
    init(viewModel: PreviousExperimentsViewModelProtocol) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            Text("Experiments (\(experiments.count))")
                .padding([.bottom], 16)
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 15) {
                    ForEach(experiments) { experiment in
                        PreviousExperimentItemView(experiment: experiment)
                            .onTapAction(perform: { action in
                                switch action {
                                case .use:
                                    useClosure(experiment.configurationURL.path())
                                case .delete:
                                    viewModel.deleteExperiment(id: experiment.id)
                                }
                            })
                    }
                }
                .padding(22)
            }
        }
        .onReceive(viewModel.viewState) { viewState in
            switch viewState {
            case let .loadExperiments(experiments):
                self.experiments = experiments
            default:
                break
            }
        }
    }
}

extension PreviousExperimentsView {
    func onUseConfiguration(perform action: @escaping(String) -> Void) -> Self {
        var copy = self
        copy.useClosure = action
        return copy
    }
    
    func onDeleteExperiment(perform action: @escaping(String) -> Void) -> Self {
        var copy = self
        copy.deleteClosure = action
        return copy
    }
}

struct PreviousExperimentsView_Previews: PreviewProvider {
    static var previews: some View {
        PreviousExperimentsView(viewModel: PreviousExperimentsViewModel.mock)
    }
}
