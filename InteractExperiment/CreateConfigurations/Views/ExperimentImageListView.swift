//
//  ExperimentImageListView.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/6/9.
//

import SwiftUI

struct ExperimentImageListView: View {
    enum PickerState: String, Identifiable {
        case familiarisation
        case stimulus
        
        var id: String { self.rawValue }
    }
    
    @State private var pickerState: PickerState?
    @ObservedObject private(set) var images: ExperimentImages
    @Binding private(set) var selectedImage: IndexSet
    @Binding var inputImage: UIImage?
    
    private let multiSelect: Bool
    
    init(pickerState: PickerState? = nil, images: ExperimentImages, selectedImage: Binding<IndexSet>, inputImage: Binding<UIImage?>, multiSelect: Bool) {
        _pickerState = .init(initialValue: pickerState)
        self.images = images
        _selectedImage = .init(projectedValue: selectedImage)
        _inputImage = .init(projectedValue: inputImage)
        self.multiSelect = multiSelect
    }
    
    var body: some View {
        HStack {
            ForEach(0..<(images.images.count + ((multiSelect || images.images.isEmpty) ? 1 : 0)), id: \.self) { index in
                if index == images.images.count {
                    Button {
                        pickerState = .familiarisation
                    } label: {
                        Image(systemName: "plus")
                            .font(.title)
                            .foregroundColor(.button.gray)
                    }
                    .frame(width: 80, height: 80)
                    .background(Color.button.lightgray)
                    .cornerRadius(8)
                } else {
                    ImageItemView(selectedIndexes: $selectedImage, index: index, image: images.images[index].image, allowMultiSelect: multiSelect)
                }
            }
        }
        .sheet(item: $pickerState, content: { state in
            ImagePicker(image: $inputImage)
        })
        .onChange(of: selectedImage) { newValue in
            guard !multiSelect else { return }
            pickerState = .familiarisation
        }
    }
}

struct ExperimentImageListView_Previews: PreviewProvider {
    static var previews: some View {
        ExperimentImageListView(images: .init(type: .stimulus), selectedImage: .constant([]), inputImage: .constant(nil), multiSelect: true)
    }
}
