//
//  CreateConfigurationView.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/5/30.
//

import SwiftUI

struct CreateConfigurationView<ViewModel>: View where ViewModel: CreateConfigurationViewModelProtocol {
    
    @State private var selectedFamiliarisation: IndexSet = []
    @State private var selectedImage: IndexSet = []
    @State private var showErrorToast: Bool = false
    @State private var instructionText: String = ""
    @FocusState private var instructionFocused: Bool
    @ObservedObject var flowState: CreateConfigFlowState
    @State private var phases: [ExperimentImagesModel]
    @State private var showAddPhaseAlert: Bool = false
    @State private var phaseName: String = ""
    
    private let viewModel: ViewModel
    
    init(flowState: CreateConfigFlowState, viewModel: ViewModel, phases: [ExperimentImagesModel]) {
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
                    showAddPhaseAlert = true
                }
                
                Section {
                    TextEditor(text: $instructionText)
                        .focused($instructionFocused)
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                Spacer()
                                Button("Done") {
                                    instructionFocused = false
                                    viewModel.update(instruction: instructionText)
                                }
                            }
                        }
                        .lineSpacing(1)
                        .padding([.top, .bottom], 10)
                        
                } header: {
                    Text("Instruction")
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
            }
#endif
        }
        })
        .toast(isPresented: $showErrorToast, type: .error, message: viewModel.currentViewState.message)
        .onReceive(viewModel.viewState) { viewState in
            switch viewState {
            case .savedAndContinue, .draftSaved:
                flowState.dismiss = true
            case .error:
                showErrorToast = true
            default:
                break
            }
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
            viewModel.appendPhase(images: phase.images, phaseName: phase.name)
        }
        viewModel.save(asDraft: asDraft)
    }
}

struct CreateConfigurationView_Previews: PreviewProvider {
    static var previews: some View {
        CreateConfigurationView(flowState: .mock, viewModel: CreateConfigurationViewModel(), phases: [.mock])
    }
}
