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
    
    init(viewModel: PreviousExperimentsViewModelProtocol) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            Text("Experiments (\(experiments.count))")
                .padding([.bottom], 16)
            ScrollView {
                LazyVStack {
                    ForEach(experiments) { experiment in
                        HStack(alignment: .top) {
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("\(experiment.date)")
                                    Text(experiment.participantId)
                                }
                                .padding([.bottom], 8)
                                Text("Familiarisation")
                                    .foregroundColor(.text.sectionTitle)
                                ScrollView {
                                    LazyHStack {
                                        ForEach(experiment.familiarisationsURLs, id: \.self) { imageURL in
                                            if let imageData = try? Data(contentsOf: imageURL),
                                               let image = UIImage(data: imageData) {
                                                ImageItemView(selectedIndexes: .constant([]), index: 0, image: image, allowMultiSelect: false)
                                            }
                                        }
                                    }
                                }
                                Text("Stimulus")
                                    .foregroundColor(.text.sectionTitle)
                                ScrollView {
                                    LazyHStack {
                                        ForEach(experiment.stimulusURLs, id: \.self) { imageURL in
                                            if let imageData = try? Data(contentsOf: imageURL),
                                               let image = UIImage(data: imageData) {
                                                ImageItemView(selectedIndexes: .constant([]), index: 0, image: image, allowMultiSelect: false)
                                            }
                                        }
                                    }
                                }
                            }
                            VStack {
                                Button("Use", action: {
                                    useClosure(experiment.id)
                                })
                                    .actionButtonStyle()
                            }
                            .padding(12)
                            
                        }
                        .padding([.bottom], 24)
                    }
                }
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
    func onUseExperiment(perform action: @escaping(String) -> Void) -> Self {
        var copy = self
        copy.useClosure = action
        return copy
    }
}

struct PreviousExperimentsView_Previews: PreviewProvider {
    static var previews: some View {
        PreviousExperimentsView(viewModel: PreviousExperimentsViewModel.mock)
    }
}
