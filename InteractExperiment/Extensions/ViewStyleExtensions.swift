//
//  ViewStyleExtensions.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/7/8.
//

import SwiftUI

extension Button {
    func actionButtonStyle() -> some View {
        self
            .font(.body)
            .padding(.init(top: 8, leading: 8, bottom: 8, trailing: 8))
            .foregroundColor(.white)
            .background(Color.blue)
            .clipShape(RoundedRectangle(cornerSize: .init(width: 6, height: 6)))
    }
}
