//
//  ExperimentPhaseSectionView.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/7/16.
//

import SwiftUI

struct ExperimentPhaseSectionView: View {
    @ObservedObject var phase: ExperimentImagesModel
    @State private var showPicker: Bool = false
    @State private var inputImage: UIImage?
    @State private var selectedIndexes: IndexSet = []
    
    var body: some View {
        Section {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(0..<(phase.images.count + ((phase.allowMultipleImages || phase.images.isEmpty) ? 1 : 0)), id: \.self) { index in
                        if index == phase.images.count {
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
                            ImageItemView(selectedIndexes: $selectedIndexes,
                                          index: index,
                                          image: phase.images[index].image,
                                          allowMultiSelect: phase.allowMultipleImages)
                                .onSelectImage { index in
                                    if phase.allowMultipleImages {
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
            }
        } header: {
            HStack {
                Text(phase.name)
                if selectedIndexes.count > 0 {
                    Button("delete") {
                        phase.remove(indexes: selectedIndexes)
                    }
                    .padding(.init(top: 2, leading: 4, bottom: 2, trailing: 4))
                    .font(.footnote)
                    .background(Color.button.red)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 3))
                }
            }
        }
        .sheet(isPresented: $showPicker, content: {
            ImagePicker(image: $inputImage)
        })
        .onChange(of: inputImage) { image in
            guard let image else { return }
            if !phase.allowMultipleImages {
                phase.reset()
            }
            phase.add(image: image)
        }
    }
}

struct ExperimentPhaseSectionView_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            ExperimentPhaseSectionView(phase: .mock)
            ExperimentPhaseSectionView(phase: .mock)
        }
    }
}
