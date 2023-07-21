//
//  ConsentFormView.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/7/18.
//

import SwiftUI

struct ConsentFormView: View {
    
    @State private var toast: ToastObject = .init()
    @State private var showLoading: Bool = false
    
    private let pdfView: PDFKitView
    private let viewModel: PreProcessViewModelProtocol
    private var finishClosure: () -> Void = { }
    
    init(viewModel: PreProcessViewModelProtocol) {
        self.viewModel = viewModel
        pdfView = PDFKitView(url: viewModel.consentFormPDF)
    }
    
    var body: some View {
        ZStack {
            pdfView
            if showLoading {
                LoadingView()
            }
        }
        .navigationTitle("Consent Form")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Clean", role: .cancel) {
                    pdfView.cleanCanvas()
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button("Continue") {
                    showLoading = true
                    defer {
                        showLoading = false
                    }
                    guard let fileURL = pdfView.makeNewPDFWithOverlay() else { return }
                    viewModel.saveConsentFormFromData(dataURL: fileURL)
                }
            }
        }
        .onReceive(viewModel.viewState) { viewState in
            switch viewState {
            case .savePDFSuccess:
                showLoading = false
                finishClosure()
            case let .loading(show):
                showLoading = show
            case let .error(message):
                showLoading = false
                toast.message = message
                toast.show = true
            }
        }
    }
}

extension ConsentFormView {
    func onFinished(perform action: @escaping() -> Void) -> Self {
        var copy = self
        copy.finishClosure = action
        return copy
    }
}

struct ConsentFormView_Previews: PreviewProvider {
    static var previews: some View {
        ConsentFormView(viewModel: PreProcessViewModel.mock)
    }
}
