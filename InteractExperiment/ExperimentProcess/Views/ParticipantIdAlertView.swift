//
//  ParticipantIdAlertView.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/6/19.
//

import SwiftUI

struct ParticipantIdAlertView: View {
    @State private var isAuthenticating = false
    @State private var participantId = ""
    @State private var isConfirmCancel = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            TextField("", text: $participantId)
                .textInputAutocapitalization(.never)
            Button("OK", action: continueProcess)
        }
    }
}

private extension ParticipantIdAlertView {
    func continueProcess() {
        
    }
}

struct ParticipantIdAlertView_Previews: PreviewProvider {
    static var previews: some View {
        ParticipantIdAlertView()
    }
}
