//
//  ExperimentView.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/6/19.
//

import SwiftUI

extension Int {
    static let HideStimulusIndex: Int = -1
}

struct ExperimentView: View {
    typealias LogAction = InteractLogModel.ActionModel.Action
    
    @State private var image: UIImage?
    @State private var lines: [Line] = []
    @State private var strokeColour: Color = .black
    @State private var stimulus: [UIImage] = []
    @State private var stimulusTabIndex: Int = .HideStimulusIndex
    @State private var showLoading: Bool = false
    @StateObject private var toast: ToastObject = .init()
    @Environment(\.displayScale) var displayScale
    
    private let viewModel: ExperimentViewModelProtocol
    var finishClosure: (() -> Void) = { }
    
    init(viewModel: ExperimentViewModelProtocol) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            if showLoading {
                ProgressView("saving...")
                    .padding(12)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerSize: .init(width: 8, height: 8)))
                    .shadow(radius: 8)
            }
            if stimulusTabIndex == .HideStimulusIndex {
                GeometryReader { geo in
                    ZStack {
                        InputPane(lines: $lines, selectedColour: $strokeColour)
                            .onAppear {
                                viewModel.setDrawingPadSize(geo.size)
                            }
                        ExperimentGestureView()
                            .onPencilDraw { state, point in
                                switch state {
                                case .began:
                                    lines.append(Line(points: [point], color: strokeColour))
                                    viewModel.appendLogAction(.drawing(true, point.x, point.y))
                                case .update:
                                    guard let lastIdx = lines.indices.last else {
                                        break
                                    }
                                    lines[lastIdx].points.append(point)
                                case .end:
                                    snapShot(size: geo.size)
                                    viewModel.appendLogAction(.drawing(false, point.x, point.y))
                                }
                            }
                            .onTwoFingersSwipe { direction in
                                switch direction {
                                case .left:
                                    //next stimulus
                                    if viewModel.experiment.state == .familiarisation {
                                        viewModel.appendFamiliarisationInputs([])
                                        finishClosure()
                                    } else {
                                        viewModel.appendStimulusInputs([])
                                        viewModel.showNextStimulus()
                                        stimulusTabIndex = viewModel.experiment.stimulusIndex
                                    }
                                case .right:
                                    //previous stimulus
                                    stimulusTabIndex = viewModel.experiment.stimulusIndex - 1
                                case .up:
                                    //do nothing
                                    stimulusTabIndex = viewModel.experiment.stimulusIndex
                                }
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
                                stimulusTabIndex = .HideStimulusIndex
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
        .toast(isPresented: $toast.show, type: toast.type, message: toast.message)
        .onReceive(viewModel.viewState) { viewState in
            switch viewState {
            case let .showNextStimulus(image):
                showLoading = false
                stimulus.append(image)
                stimulusTabIndex = stimulus.count - 1
            case .endFamiliarisation, .endTrial:
                showLoading = false
                finishClosure()
            case .loading:
                showLoading = true
            case let .error(message):
                toast.message = message
                toast.show = true
            default:
                showLoading = false
                break
            }
        }
        .onChange(of: stimulusTabIndex) { [oldIndex = stimulusTabIndex] stimulusIndex_new in
            let isOn = stimulusIndex_new != .HideStimulusIndex
            let imageIndex = isOn ? stimulusIndex_new : oldIndex
            if viewModel.experiment.state == .familiarisation,
                let filename = viewModel.configuration.familiarImages.last {
                viewModel.appendLogAction(.familiarisation(isOn, filename))
            } else if case .stimulus = viewModel.experiment.state,
                      imageIndex < viewModel.configuration.stimulusImages.count {
                let fileName = viewModel.configuration.stimulusImages[imageIndex]
                viewModel.appendLogAction(.stimulus(isOn, fileName))
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

private extension ExperimentView {
    @MainActor
    func snapShot(size: CGSize) {
        let canvas = InputPane(lines: $lines, selectedColour: $strokeColour)
            .frame(width: size.width, height: size.height)
        let renderer = ImageRenderer(content: canvas)

        // make sure and use the correct display scale for this device
        renderer.scale = displayScale

        if let snapshot = renderer.uiImage {
            viewModel.appendSnapshot(image: snapshot)
        }
    }
}

struct ExperimentView_Previews: PreviewProvider {
    static var previews: some View {
        ExperimentView(viewModel: ExperimentViewModel.mock)
    }
}
