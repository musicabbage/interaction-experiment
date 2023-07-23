//
//  LoadingView.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/7/20.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        ProgressView("saving...")
            .padding(12)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerSize: .init(width: 8, height: 8)))
            .shadow(radius: 8)
    }
}
