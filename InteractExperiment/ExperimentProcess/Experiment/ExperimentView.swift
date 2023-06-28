//
//  ExperimentView.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/6/19.
//

import SwiftUI

struct ExperimentView<ViewModel: ExperimentViewModelProtocol>: View {
    
    @State private var image: UIImage?
    
    private let viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            if let image {
                Image(uiImage: image)
            }
        }
        .onReceive(viewModel.viewState) { viewState in
            switch viewState {
            case let .displayImage(image):
                self.image = image
            default:
                break
            }
        }
    }
}

struct ExperimentView_Previews: PreviewProvider {
    static var previews: some View {
        ExperimentView(viewModel: ExperimentViewModel.mock)
    }
}
