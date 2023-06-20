//
//  ExperimentImageListView.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/6/9.
//

import SwiftUI

struct ExperimentImageListView: View {
    
    @State private var showPicker: Bool
    @ObservedObject private(set) var images: ExperimentImages
    @Binding private(set) var selectedIndexes: IndexSet
    @Binding var inputImage: UIImage?
    
    private let multiSelect: Bool
    
    init(images: ExperimentImages, selectedImage: Binding<IndexSet>, inputImage: Binding<UIImage?>, multiSelect: Bool) {
        _showPicker = .init(initialValue: false)
        _selectedIndexes = .init(projectedValue: selectedImage)
        _inputImage = .init(projectedValue: inputImage)
        self.images = images
        self.multiSelect = multiSelect
    }
    
    var body: some View {
        HStack {
            ForEach(0..<(images.images.count + ((multiSelect || images.images.isEmpty) ? 1 : 0)), id: \.self) { index in
                if index == images.images.count {
                    Button {
                        showPicker = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.title)
                            .foregroundColor(.button.gray)
                    }
                    .frame(width: 80, height: 80)
                    .background(Color.button.lightgray)
                    .cornerRadius(8)
                } else {
                    ImageItemView(selectedIndexes: $selectedIndexes, index: index, image: images.images[index].image, allowMultiSelect: multiSelect)
                        .selectImage { index in
                            if multiSelect {
                                if selectedIndexes.contains(index) {
                                    selectedIndexes.remove(index)
                                } else {
                                    selectedIndexes.insert(index)
                                }
                            } else {
                                showPicker = true
                            }
                        }
                }
            }
        }
        .sheet(isPresented: $showPicker, content: {
            ImagePicker(image: $inputImage)
        })
        .onChange(of: selectedIndexes) { newValue in
            guard !multiSelect else { return }
            showPicker = true
        }
    }
}

struct ExperimentImageListView_Previews: PreviewProvider {
    static var previews: some View {
        ExperimentImageListView(images: .init(type: .stimulus), selectedImage: .constant([]), inputImage: .constant(nil), multiSelect: true)
    }
}
