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
    
    @ObservedObject private var viewModel: ViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        _instructionText = .init(initialValue: viewModel.configurations.instruction)
    }
    
    var body: some View {
        NavigationStack {
            
            Form {
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        //familiarisation
                        ExperimentImageListView(images: viewModel.familiarImages,
                                                selectedImage: $selectedFamiliarisation,
                                                multiSelect: false)
                        .onAddNewImage { image in
                            viewModel.append(image: image, type: .familiarisation)
                        }
                    }
                } header: {
                    Text("Familiarisation")
                }
                
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        //stimulus
                        ExperimentImageListView(images: viewModel.stimulusImages,
                                                selectedImage: $selectedImage,
                                                multiSelect: true)
                        .onAddNewImage { image in
                            viewModel.append(image: image, type: .stimulus)
                        }
                    }
                } header: {
                    HStack {
                        Text("Stimulus")
                            .padding(.init(top: 0, leading: 0, bottom: 0, trailing: 10))
                        Button("delete") {
                            viewModel.deleteImages(indexes: selectedImage, type: .stimulus)
                            selectedImage.removeAll()
                        }
                        .padding(.init(top: 2, leading: 4, bottom: 2, trailing: 4))
                        .font(.footnote)
                        .background(Color.button.red)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 3))
                    }
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
            .onTapGesture {
                
            }
#if os(macOS)
            .frame(maxWidth: .infinity)
#else
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Save") {
                        viewModel.save()
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    Button("save and start a new experiment") {
                        viewModel.save()
                    }
                    .font(.body)
                    .padding(.init(top: 8, leading: 8, bottom: 8, trailing: 8))
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerSize: .init(width: 6, height: 6)))
                }
            }
#endif
        }
        .toast(isPresented: $showErrorToast, type: .error, message: viewModel.viewState.message)
        .onChange(of: viewModel.viewState) { viewState in
            switch viewState {
            case .savedAndContinue:
                dismiss()
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

struct CreateConfigurationView_Previews: PreviewProvider {
    static var previews: some View {
        CreateConfigurationView(viewModel: CreateConfigurationViewModel())
    }
}
