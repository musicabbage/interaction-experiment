//
//  ImageItemView.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/6/4.
//

import SwiftUI

struct ImageItemView: View {
    
    private var checked: Bool { selectedIndexes.contains(index) }
    
    @State private var selected: Bool = false
    @Binding var selectedIndexes: IndexSet

    let index: Int
    let image: UIImage
    let allowMultiSelect: Bool
    
    var body: some View {
        ZStack(alignment: .center) {
            Button {
                selected.toggle()
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
                Image(systemName: checked ? "checkmark.circle.fill" : "circle.fill")
                    .resizable()
                    .foregroundColor(checked ? .checkBox.checked : .checkBox.unchecked)
                    .background(checked ? .white : .clear)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                    )
                    .frame(width: 20, height: 20)
                    .position(x: 60, y: 25)
            }
        }
        .onChange(of: selected) { selected in
            if checked {
                selectedIndexes.remove(index)
            } else {
                selectedIndexes.insert(index)
            }
        }
    }
}

struct ImageItemView_Previews: PreviewProvider {
    static var previews: some View {
        ImageItemView(selectedIndexes: .constant([]), index: 0, image: .init(named: "TestStimulus")!, allowMultiSelect: true)
    }
}
