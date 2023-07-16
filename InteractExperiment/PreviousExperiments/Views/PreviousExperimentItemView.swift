//
//  PreviousExperimentItemView.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/7/9.
//

import SwiftUI

struct PreviousExperimentItemView: View {
    
    enum Action {
        case use, delete
    }
    
    private var actionClosure: ((Action) -> Void) = { _ in }
    
    let experiment: PreviousExperimentsModel
    
    init(actionClosure: @escaping((Action) -> Void) = { _ in }, experiment: PreviousExperimentsModel) {
        self.actionClosure = actionClosure
        self.experiment = experiment
    }
    
    var body: some View {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    HStack(alignment: .top) {
                        Text("\(experiment.date)")
                        Spacer()
                        Text(experiment.participantId)
                    }
                    ForEach(0..<experiment.phases.count, id: \.self) { index in
                        PreviousExperimentImageListView(title: experiment.phases[index].first!.key, images: experiment.phases[index].first!.value)
                                                .padding([.vertical], 2)
                    }
                }
                VStack {
                    Button("Use", action: {
                        actionClosure(.use)
                    })
                    .actionButtonStyle()
                }
                .frame(width: 220)
            }
            .padding(16)
            .frame(height: 320)
            .background(Color.background.lightgray)
            .cornerRadius(15)
    }
}

fileprivate struct PreviousExperimentImageListView: View {
    
    let title: String
    let images: [UIImage]
    
    var body: some View {
        Text(title)
            .foregroundColor(.text.sectionTitle)
        ScrollView {
            LazyHStack {
                ForEach(images, id: \.self) { image in
                    ImageItemView(selectedIndexes: .constant([]), index: 0, image: image, allowMultiSelect: false)
                }
            }
        }
    }
}

extension PreviousExperimentItemView {
    func onTapAction(perform action: @escaping(Action) -> Void) -> Self {
        var copy = self
        copy.actionClosure = action
        return copy
    }
}

struct PreviousExperimentItemView_Previews: PreviewProvider {
    static var previews: some View {
        PreviousExperimentItemView(experiment: .mock)
    }
}
