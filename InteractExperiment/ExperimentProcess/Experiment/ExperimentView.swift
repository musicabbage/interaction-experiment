//
//  ExperimentView.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/6/19.
//

import SwiftUI

struct ExperimentView: View {
    
    @State private var image: UIImage?
    @State private var showDrawing: Bool = false
    @State private var lines: [Line] = []
    
    private let viewModel: ExperimentViewModelProtocol
    var finishClosure: (() -> Void) = { }
    
    init(viewModel: ExperimentViewModelProtocol) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            if showDrawing {
                InputPane(lines: $lines)
                    .gesture(
                        MagnificationGesture()
                            .onChanged({ value in
                                guard value > 0.85 && value < 1.1 else { return }
                                viewModel.showStimulus()
                            }))
            } else if let image {
                Image(uiImage: image)
                    .onTapGesture {
                        showDrawing = true
                    }
            }
        }
        .onReceive(viewModel.viewState) { viewState in
            switch viewState {
            case let .showStimulus(image):
                showDrawing = false
                self.image = image
            case .startStimulus:
                finishClosure()
            default:
                break
            }
        }
    }
}

extension ExperimentView {
    func onFinished(perform action: @escaping() -> Void) -> Self {
        var copy = self
        copy.finishClosure = action
        return copy
    }
}

struct ExperimentView_Previews: PreviewProvider {
    static var previews: some View {
        ExperimentView(viewModel: ExperimentViewModel.mock)
    }
}
