//
//  CreateConfigurationView.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/5/30.
//

import SwiftUI

struct CreateConfigurationView: View {
    enum PickerState: String, Identifiable {
        case familiriarisation
        case stimulus
        
        var id: String { self.rawValue }
    }
    
    @State private var inputImage: UIImage?
    @State private var familirImages: [UIImage] = []
    @State private var stimulusImages: [UIImage] = []
    @State private var pickerState: PickerState?
    
    @Environment(\.dismiss) var dismiss
    
    private let maxStimulusCount: Int = 10
    
    
    var body: some View {
        NavigationStack {
            
            Form {
                Section {
                    HStack {
                        ForEach(0...familirImages.count, id: \.self) { index in
                            if index == familirImages.count {
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
                                Image(uiImage: familirImages[index])
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(8)
                                    .clipped()
                            }
                        }
                    }
                } header: {
                    Text("Familiriarisation")
                }
                
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(0..<stimulusImages.count, id: \.self) { index in
                                Image(uiImage: stimulusImages[index])
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(8)
                                    .clipped()
                            }
                            if stimulusImages.count < maxStimulusCount {
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
                        Text("Stimulus (\(stimulusImages.count)/\(maxStimulusCount))")
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
            familirImages.append(inputImage)
        case .stimulus:
            stimulusImages.append(inputImage)
        }
        
    }

}

struct CreateConfigurationView_Previews: PreviewProvider {
    static var previews: some View {
        CreateConfigurationView()
    }
}
