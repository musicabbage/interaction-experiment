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
    
    private let showStimulusWhenDrawing: Bool
    private let viewModel: ExperimentViewModelProtocol
    private var finishClosure: ((ConfigurationModel, InteractLogModel) -> Void) = { _,_ in }
    
    init(viewModel: ExperimentViewModelProtocol) {
        self.viewModel = viewModel
        if viewModel.experiment.phaseIndex < viewModel.configuration.phases.count {
            let phase = viewModel.configuration.phases[viewModel.experiment.phaseIndex]
            self.showStimulusWhenDrawing = phase.showStimulusWhenDrawing
        } else {
            self.showStimulusWhenDrawing = false
        }
    }
    
    var body: some View {
        ZStack {
            if showStimulusWhenDrawing || (stimulusTabIndex != .HideStimulusIndex) {
                TabView(selection: $stimulusTabIndex) {
                    ForEach(0..<stimulus.count, id: \.self) { index in
                        Image(uiImage: stimulus[index])
                            .resizable()
                            .scaledToFit()
                            .onTapGesture {
                                guard !showStimulusWhenDrawing else { return }
                                stimulusTabIndex = .HideStimulusIndex
                            }
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle())
            }
            
            if showStimulusWhenDrawing || stimulusTabIndex == .HideStimulusIndex {
                GeometryReader { geo in
                    ZStack {
                        InputPane(lines: $lines, selectedColour: $strokeColour)
                            .onAppear {
                                viewModel.setDrawingPadSize(geo.size)
                            }
                        ExperimentGestureView()
                            .onPencilDraw { state, drawing in
                                let point = drawing.point
                                switch state {
                                case .began:
                                    lines.append(Line(points: [point], color: strokeColour))
                                    viewModel.appendLogAction(.drawing(true, drawing))
                                    viewModel.resetDrawingData()
                                case .update:
                                    guard let lastIdx = lines.indices.last else {
                                        break
                                    }
                                    lines[lastIdx].points.append(point)
                                    viewModel.appendDrawingData(drawing)
                                case .end:
                                    snapShot(size: geo.size)
                                    viewModel.appendLogAction(.drawing(false, drawing))
                                    let avgDrawing = viewModel.collectAverageDrawingData()
                                    viewModel.appendLogAction(.pencilDrawing(avgDrawing))
                                }
                            }
                            .onTwoFingersSwipe { direction in
                                switch direction {
                                case .left:
                                    viewModel.showNextStimulus()
                                    stimulusTabIndex = viewModel.experiment.stimulusIndex
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
            }
            
            if showLoading {
                LoadingView()
            }
        }
        .onAppear {
            if viewModel.experiment.phaseIndex == 0 && viewModel.experiment.stimulusIndex == 0 {
                viewModel.appendLogAction(.drawingEnabled)
            }
        }
        .toast(isPresented: $toast.show, type: toast.type, message: toast.message)
        .onReceive(viewModel.viewState) { viewState in
            switch viewState {
            case .loading:
                showLoading = true
            case let .showNextStimulus(image):
                showLoading = false
                stimulus.append(image)
                stimulusTabIndex = stimulus.count - 1
            case .endPhase, .endTrial:
                showLoading = false
                finishClosure(viewModel.configuration, viewModel.experiment)
            case let .error(message):
                toast.message = message
                toast.show = true
            default:
                showLoading = false
            }
        }
        .onChange(of: stimulusTabIndex) { [oldIndex = stimulusTabIndex] stimulusIndex_new in
            let isOn = stimulusIndex_new != .HideStimulusIndex
            let imageIndex = isOn ? stimulusIndex_new : oldIndex
            guard let phase = viewModel.currentPhase, phase.images.count > imageIndex else { return }
            viewModel.appendLogAction(.stimulusDisplay(isShow: isOn, phaseName: phase.name, fileName: phase.images[imageIndex]))
        }
    }
}

extension ExperimentView {
    func onFinished(perform action: @escaping(ConfigurationModel, InteractLogModel) -> Void) -> Self {
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
