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
    
    var body: some View {
        HStack {
            ForEach(0...images.images.count, id: \.self) { index in
                if index == images.images.count {
                    Button {
                        pickerState = .familiarisation
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
                    ImageItemView(selectedIndexes: $selectedImage, index: index, image: images.images[index].image)
                }
            }
        }
    }
}

struct ExperimentImageListView_Previews: PreviewProvider {
    static var previews: some View {
        ExperimentImageListView(images: .init(type: .stimulus), selectedImage: .constant([]), inputImage: .constant(nil))
    }
}
