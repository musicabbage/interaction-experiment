//
//  ImageItemView.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/6/4.
//

import SwiftUI

struct ImageItemView: View {
    
    @State private var selected: Bool = false
    @Binding var selectedIndexes: IndexSet

    let index: Int
    let image: UIImage
    
//    init(selected: Bool, selectedIndexes: IndexSet, index: Int, image: UIImage) {
//        self.selected = selected
//        self.selectedIndexes = selectedIndexes
//        self.index = index
//        self.image = image
//    }
//    init(selectedIndexes: IndexSet, index: Int, image: UIImage) {
//        self.selectedIndexes = selectedIndexes
//        self.index = index
//        self.image = image
//    }
    
    var body: some View {
        ZStack(alignment: .center) {
            Button {
                selected.toggle()
            } label: {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .clipped()
            }
            .frame(width: 80, height: 80)
            .cornerRadius(8)
            
            Image(systemName: selected ? "checkmark.circle.fill" : "circle.fill")
                .foregroundStyle(Color.gray)
                .position(x: 65, y: 20)
        }
        .onChange(of: selected) { selected in
            if selected {
                selectedIndexes.insert(index)
            } else {
                selectedIndexes.remove(index)
            }
        }
    }
}

struct ImageItemView_Previews: PreviewProvider {
    static var previews: some View {
        ImageItemView(selectedIndexes: .constant([]), index: 0, image: .init(named: "TestStimulus")!)
    }
}
