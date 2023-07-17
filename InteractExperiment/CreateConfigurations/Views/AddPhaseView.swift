//
//  AddPhaseView.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/7/17.
//

import SwiftUI

struct AddPhaseView: View {
    @State private var phaseName: String = ""
    @State private var allowMultipleImages: Bool = true
    @State private var showStimulusWhenDrawing: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    private var addClosure: (ExperimentImagesModel) -> Void = { _ in }
    
    var body: some View {
        Form {
            Section {
                TextField("Name", text: $phaseName)
                Toggle("Allow multiple images", isOn: $allowMultipleImages)
                Toggle("Show stimulus when drawing", isOn: $showStimulusWhenDrawing)
            }
            Button(action: {
                let phase = ExperimentImagesModel(type: .custom(phaseName))
                phase.allowMultipleImages = allowMultipleImages
                addClosure(phase)
                dismiss()
            }, label: {
                HStack {
                    Spacer()
                    Text("Add")
                    Spacer()
                }
            })
        }
    }
}

extension AddPhaseView {
    func onSaveAction(perform action: @escaping(ExperimentImagesModel) -> Void) -> Self {
        var copy = self
        copy.addClosure = action
        return copy
    }
}

struct AddPhaseView_Previews: PreviewProvider {
    static var previews: some View {
        AddPhaseView()
    }
}
