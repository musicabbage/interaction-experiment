//
//  CreateConfigurationView.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/5/30.
//

import SwiftUI

struct CreateConfigurationView<ViewModel>: View where ViewModel: CreateConfigurationViewModelProtocol {
    
    @State private var selectedImage: IndexSet = []
    @State private var newFamiliarisationImage: UIImage?
    @State private var newStimulusImage: UIImage?
    @State private var showErrorToast: Bool = false
    
    @ObservedObject private var viewModel: ViewModel
    
    @Environment(\.dismiss) var dismiss
    
    private let maxStimulusCount: Int = 10
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            
            Form {
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        ExperimentImageListView(images: viewModel.familiarImages, selectedImage: .constant([]), inputImage: $newFamiliarisationImage)
                    }
                } header: {
                    Text("Familiarisation")
                }
                
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        ExperimentImageListView(images: viewModel.stimulusImages, selectedImage: $selectedImage, inputImage: $newStimulusImage)
                    }
                } header: {
                    HStack {
                        Text("Stimulus (\(viewModel.stimulusImages.images.count)/\(maxStimulusCount))")
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
        .onChange(of: newFamiliarisationImage) { image in
            guard let image else { return }
            viewModel.append(image: image, type: .familiarisation)
        }
        .onChange(of: newStimulusImage) { image in
            guard let image else { return }
            viewModel.append(image: image, type: .stimulus)
        }
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
