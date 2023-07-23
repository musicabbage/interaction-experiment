//
//  PracticeView.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/7/20.
//

import SwiftUI

struct PracticeView: View {
    
    @State var imageName: String?
    @State var instructionMessage: String?
    
    var finishClosure: ((ConfigurationModel, InteractLogModel) -> Void) = { _,_ in }
    let viewModel: PracticeViewModel
    
    var body: some View {
        ZStack {
            ExperimentView(viewModel: viewModel)
                .onFinished(perform: finishClosure)
            if let imageName {
                VStack {
                    Spacer()
                    HStack(alignment: .top) {
                        Spacer()
                        Image(imageName)
                    }
                    .padding(10)
                }
            }
            
            if let instructionMessage {
                ZStack {
                    Image("Practice_bubble")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 900, height: 600)
                    Text(instructionMessage)
                        .font(Font.custom("Chalkboard SE", size: 24))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 500)
                        .offset(.init(width: 20, height: -50))
                }
                .offset(.init(width: 200, height: -50))
                .onTapGesture {
                    self.instructionMessage = nil
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onReceive(viewModel.stepViewState) { stepState in
            if case let .showTutorial(step) = stepState {
                switch step {
                case .tap:
                    imageName = "Practice_tap"
                case .swipeUp:
                    imageName = "Practice_swipe_up"
                case .swipeLeft:
                    imageName = "Practice_swipe_left"
                case .swipeRight:
                    imageName = "Practice_swipe_right"
                case .swipeRightTwoFingers:
                    imageName = "Practice_swipe_right_two"
                case .nextPhase:
                    imageName = "Practice_next_phase"
                }
            } else {
                imageName = nil
                if case .endTutorial(let string) = stepState {
                    instructionMessage = string
                }
            }
        }
    }
}

extension PracticeView {
    func onFinished(perform action: @escaping(ConfigurationModel, InteractLogModel) -> Void) -> Self {
        var copy = self
        copy.finishClosure = action
        return copy
    }
}

struct PracticeView_Previews: PreviewProvider {
    static var previews: some View {
        PracticeView(viewModel: .init(group: .A))
    }
}
