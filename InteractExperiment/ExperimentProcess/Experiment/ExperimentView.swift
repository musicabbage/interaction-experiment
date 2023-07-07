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
    @State private var strokeColour: Color = .black
    @State private var stimulus: [UIImage] = []
    @State private var stimulusTabIndex: Int = 0
    @State private var drawingActions: [LineAction] = []
    
    private let viewModel: ExperimentViewModelProtocol
    var finishClosure: (() -> Void) = { }
    
    init(viewModel: ExperimentViewModelProtocol) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            if showDrawing {
                ZStack {
                    InputPane(lines: $lines, drawingActions: $drawingActions, selectedColour: $strokeColour)
                    ExperimentGestureView()
                        .onDrag { state, point in
                            switch state {
                            case .began:
                                lines.append(Line(points: [point], color: strokeColour))
                            case .update:
                                guard let lastIdx = lines.indices.last else {
                                    break
                                }
                                lines[lastIdx].points.append(point)
                            case .end:
                                break
                            }
                        }
                        .onTwoFingersSwipe { direction in
                            showDrawing = false
                            switch direction {
                            case .left:
                                //next stimulus
                                viewModel.showNextStimulus()
                            case .right:
                                //previous stimulus
                                stimulusTabIndex -= 1
                            case .up:
                                //do nothing
                                break
                            }
                        }
                }
            } else if stimulus.count > 0 {
                TabView(selection: $stimulusTabIndex) {
                    ForEach(0..<stimulus.count, id: \.self) { index in
                        Image(uiImage: stimulus[index])
                            .resizable()
                            .scaledToFit()
                            .onTapGesture {
                                showDrawing = true
                                stimulusTabIndex = viewModel.experiment.stimulusIndex
                            }
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle())
            }
        }
        .onAppear {
            if viewModel.experiment.state == .familiarisation {
                viewModel.appendLogAction(.drawingEnabled)
            }
        }
        .onChange(of: showDrawing, perform: { isShow in
            guard isShow else { return }
            if viewModel.experiment.state == .familiarisation {
                let fileName = viewModel.configuration.familiarImages.first ?? ""
                viewModel.appendLogAction(.familiarisation(false, fileName))
            } else if case let .stimulus(index) = viewModel.experiment.state {
                let fileName = viewModel.configuration.stimulusImages[index]
                viewModel.appendLogAction(.stimulus(false, fileName))
            }
        })
        .onReceive(viewModel.viewState) { viewState in
            switch viewState {
            case let .showStimulus(image):
                showDrawing = false
                stimulus.append(image)
                stimulusTabIndex = stimulus.count - 1
            case .endFamiliarisation, .endTrial:
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
