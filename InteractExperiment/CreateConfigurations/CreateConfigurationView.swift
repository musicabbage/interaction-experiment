//
//  CreateConfigurationView.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/5/30.
//

import SwiftUI

struct CreateConfigurationView: View {
    
    @State private var selectedFamiliarisation: IndexSet = []
    @State private var selectedImage: IndexSet = []
    @State private var showErrorToast: Bool = false
    @State private var instructionText: String = ""
    @State private var phases: [ExperimentImagesModel]
    @State private var showAddPhaseSheet: Bool = false
    @State private var defaultParticipantId: String = ""
    @FocusState private var participantIdKeyboardFocused: Bool
    @FocusState private var instructionKeyboardFocused: Bool
    @ObservedObject var flowState: CreateConfigFlowState
    
    private let viewModel: CreateConfigurationViewModelProtocol
    
    init(flowState: CreateConfigFlowState, viewModel: CreateConfigurationViewModelProtocol, phases: [ExperimentImagesModel]) {
        _instructionText = .init(initialValue: viewModel.configurations.instruction)
        self.flowState = flowState
        self.viewModel = viewModel
        _phases = .init(initialValue: phases)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                ForEach(phases) { phase in
                    ExperimentPhaseSectionView(phase: phase)
                }
                
                Button("Add Phase") {
                    showAddPhaseSheet = true
                }
                
                Section {
                    TextEditor(text: $instructionText)
                        .focused($instructionKeyboardFocused)
                        .lineSpacing(1)
                        .frame(minHeight: 100)
                        .padding([.top, .bottom], 10)
                } header: {
                    Text("Instruction")
                }
                
                Section {
                    TextEditor(text: $defaultParticipantId)
                        .focused($participantIdKeyboardFocused)
                        .lineSpacing(1)
                        .padding([.top, .bottom], 10)
                        
                } header: {
                    Text("Default Participant ID")
                }
            }
#if os(macOS)
            .frame(maxWidth: .infinity)
#else
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        flowState.dismiss = true
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Save") {
                        saveConfiguration(asDraft: true)
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    Button("save and start a new experiment") {
                        saveConfiguration(asDraft: false)
                    }
                    .actionButtonStyle()
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        participantIdKeyboardFocused = false
                        instructionKeyboardFocused = false
                    }
                }
            }
#endif
        }
        .sheet(isPresented: $showAddPhaseSheet, content: {
            AddPhaseView()
                .onSaveAction { phase in
                    phases.append(phase)
                }
        })
        .toast(isPresented: $showErrorToast, type: .error, message: viewModel.currentViewState.message)
        .onReceive(viewModel.viewState) { viewState in
            switch viewState {
            case let .loadDraft(configuration):
                instructionText = configuration.instruction
                defaultParticipantId = configuration.defaultParticipantId
                var imagesModels: [ExperimentImagesModel] = []
                for phase in configuration.phases {
                    var model = ExperimentImagesModel(type: .init(name: phase.name))
                    for image in phase.images {
                        let imagePath = configuration.folderURL.appending(path: image)
                        if let data = try? Data(contentsOf: imagePath),
                           let image = UIImage(data: data) {
                            model.add(image: image)
                        }
                    }
                    imagesModels.append(model)
                }
                phases = imagesModels
            case .savedAndContinue, .draftSaved:
                flowState.dismiss = true
            case .error:
                showErrorToast = true
            default:
                break
            }
        }
        .onChange(of: instructionKeyboardFocused) { newValue in
            viewModel.update(instruction: instructionText)
        }
        .onChange(of: participantIdKeyboardFocused) { newValue in
            viewModel.update(defaultParticipantId: defaultParticipantId)
        }
#if os(macOS)
        .background(Color.red)
        .frame(width: 600, height: 350)
#endif
    }

}

private extension CreateConfigurationView {
    func saveConfiguration(asDraft: Bool) {
        for phase in phases {
            guard !phase.images.isEmpty else { continue }
            viewModel.appendPhase(images: phase.images,
                                  phaseName: phase.name,
                                  showStimulusWhenDrawing: phase.showStimulusWhenDrawing)
        }
        viewModel.save(asDraft: asDraft)
    }
}

struct CreateConfigurationView_Previews: PreviewProvider {
    static var previews: some View {
        CreateConfigurationView(flowState: .mock, viewModel: CreateConfigurationViewModel(), phases: [.mock])
    }
}
