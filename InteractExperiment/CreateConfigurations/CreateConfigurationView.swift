//
//  CreateConfigurationView.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/5/30.
//

import SwiftUI

struct CreateConfigurationView<ViewModel>: View where ViewModel: CreateConfigurationViewModelProtocol {
    enum PickerState: String, Identifiable {
        case familiriarisation
        case stimulus
        
        var id: String { self.rawValue }
    }
    
    @State private var inputImage: UIImage?
    @State private var pickerState: PickerState?
    @StateObject private var viewModel: ViewModel
    
    @Environment(\.dismiss) var dismiss
    
    private let maxStimulusCount: Int = 10
    
    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            
            Form {
                Section {
                    HStack {
                        ForEach(0...viewModel.familiarImages.count, id: \.self) { index in
                            if index == viewModel.familiarImages.count {
                                Button {
                                    pickerState = .familiriarisation
                                } label: {
                                    Image(systemName: "plus")
                                        .font(.title)
                                        .foregroundColor(.button.gray)
                                }
                                .sheet(item: $pickerState, content: { state in
                                    ImagePicker(image: $inputImage)
                                })
                                .frame(width: 80, height: 80)
                                .background(Color.button.lightgray)
                                .cornerRadius(8)
                            } else {
                                viewModel.familiarImages[index].image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(8)
                                    .clipped()
//                                ImageItemView(selected: <#T##Bool#>, image: <#T##UIImage#>)
                            }
                        }
                    }
                } header: {
                    Text("Familiarisation")
                }
                
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(0..<viewModel.stimulusImages.count, id: \.self) { index in
                                viewModel.stimulusImages[index].image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(8)
                                    .clipped()
                            }
                            if viewModel.stimulusImages.count < maxStimulusCount {
                                Button {
                                    pickerState = .stimulus
                                } label: {
                                    Image(systemName: "plus")
                                        .font(.title)
                                        .foregroundColor(.button.gray)
                                }
                                .sheet(item: $pickerState, content: { state in
                                    ImagePicker(image: $inputImage)
                                })
                                .frame(width: 80, height: 80)
                                .background(Color.button.lightgray)
                                .cornerRadius(8)
                            }
                        }
                    }
                } header: {
                    HStack {
                        Text("Stimulus (\(viewModel.stimulusImages.count)/\(maxStimulusCount))")
                            .padding(.init(top: 0, leading: 0, bottom: 0, trailing: 10))
                        Button("delete") {
                            
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
                        
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    Button("save and start a new experiment") {
                        
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
        .onChange(of: inputImage) { _ in loadImage() }
#if os(macOS)
        .background(Color.red)
        .frame(width: 600, height: 350)
#endif
    }
    
    func loadImage() {
        guard let inputImage, let pickerState else { return }
        switch pickerState {
        case .familiriarisation:
//            familirImages.append(inputImage)
            viewModel.appendFamiliarization(image: .init(uiImage: inputImage))
        case .stimulus:
//            stimulusImages.append(inputImage)
            viewModel.appendStimulus(image: .init(uiImage: inputImage))
        }
        
    }

}

struct CreateConfigurationView_Previews: PreviewProvider {
    static var previews: some View {
        CreateConfigurationView(viewModel: ViewModel())
//        CreateConfigurationView(viewModel: CreateConfigurationView<<#ViewModel: CreateConfigurationViewModelProtocol#>>.ViewModel())
    }
}
