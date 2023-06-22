//
//  ParticipantIdAlertView.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/6/19.
//

import SwiftUI

struct ParticipantIdAlertView: View {
    @State private var participantId: String = ""
    var confirmClosure: ((String) -> Void)?
    
    var body: some View {
        VStack {
            TextField("", text: $participantId)
            Button("OK", action: continueProcess)
        }
    }
}

extension ParticipantIdAlertView {
    func onConfirmParticipantId(perform action: @escaping(String) -> Void) -> Self {
        var copy = self
        copy.confirmClosure = action
        return copy
    }
}

private extension ParticipantIdAlertView {
    func continueProcess() {
        guard let confirmClosure else { return }
        confirmClosure(participantId)
    }
}

struct ParticipantIdAlertView_Previews: PreviewProvider {
    static var previews: some View {
        ParticipantIdAlertView()
    }
}
