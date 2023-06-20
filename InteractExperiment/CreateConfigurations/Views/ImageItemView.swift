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
    let allowMultiSelect: Bool
    var action: ((Int) -> Void)?
    
    var body: some View {
        ZStack(alignment: .center) {
            Button {
                guard let action else { return }
                action(index)
            } label: {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.gray, lineWidth: 0.5)
                    )
            }
            
            if allowMultiSelect {
                Image(systemName: selected ? "checkmark.circle.fill" : "circle.fill")
                    .resizable()
                    .foregroundColor(selected ? .checkBox.checked : .checkBox.unchecked)
                    .background(selected ? .white : .clear)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                    )
                    .frame(width: 20, height: 20)
                    .position(x: 60, y: 25)
            }
        }
        .onChange(of: selectedIndexes) { indexes in
            selected = selectedIndexes.contains(index)
        }
    }
}

extension ImageItemView {
    func selectImage(perform action: @escaping (Int) -> Void) -> Self {
        var copy = self
        copy.action = action
        return copy
    }
}

struct ImageItemView_Previews: PreviewProvider {
    static var previews: some View {
        ImageItemView(selectedIndexes: .constant([]), index: 0, image: .init(named: "TestStimulus")!, allowMultiSelect: true)
    }
}
