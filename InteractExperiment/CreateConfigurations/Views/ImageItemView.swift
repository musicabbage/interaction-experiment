//
//  ImageItemView.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/6/4.
//

import SwiftUI

struct ImageItemView: View {
    
    @Binding var selected: Bool
    
    var image: UIImage
    
    var body: some View {
        ZStack {
            Button {
                selected.toggle()
            } label: {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .clipped()
            }
            Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(Color.gray)
                .position(x: 105, y: 15)
        }
        .frame(width: 80, height: 80)
        .cornerRadius(8)
    }
}

struct ImageItemView_Previews: PreviewProvider {
    static var previews: some View {
        ImageItemView(selected: .constant(true), image: UIImage(named: "TestStimulus")!)
            .padding(15)
            .background(Color.gray)
    }
}
