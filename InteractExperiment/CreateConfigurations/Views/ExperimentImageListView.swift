//
//  ExperimentImageListView.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/6/9.
//

import SwiftUI

struct ExperimentImageListView: View {
    
    @State private var showPicker: Bool
    @State private var inputImage: UIImage?
    @ObservedObject private(set) var images: ExperimentImages
    @Binding private(set) var selectedIndexes: IndexSet
    
    private let multiSelect: Bool
    var newImageClosure: ((UIImage) -> Void)?
    
    init(images: ExperimentImages, selectedImage: Binding<IndexSet>, multiSelect: Bool) {
        _showPicker = .init(initialValue: false)
        _selectedIndexes = .init(projectedValue: selectedImage)
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
                        .onSelectImage { index in
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
        .onChange(of: selectedIndexes) { _ in
            guard !multiSelect else { return }
            showPicker = true
        }
        .onChange(of: inputImage) { image in
            guard let newImageClosure, let image else { return }
            newImageClosure(image)
        }
    }
}

extension ExperimentImageListView {
    func onAddNewImage(perform action: @escaping(UIImage) -> Void) -> Self {
        var copy = self
        copy.newImageClosure = action
        return copy
    }
}

struct ExperimentImageListView_Previews: PreviewProvider {
    static var previews: some View {
        ExperimentImageListView(images: .init(type: .stimulus), selectedImage: .constant([]), multiSelect: true)
    }
}
