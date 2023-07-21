//
//  QuestionnaireView.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/7/20.
//

import SwiftUI
import WebKit

struct QuestionnaireView: View {
    
    @State private var showLoading: Bool = false
    
    private let webView: WebView
    private let viewModel: PreProcessViewModelProtocol
    private var finishClosure: () -> Void = { }
    
    init(viewModel: PreProcessViewModelProtocol) {
        self.viewModel = viewModel
        
        //clean all cache, so that the questionnaire can be sent by multiple times
        WebView.cleanAllCache()
        let request = URLRequest(url: viewModel.questionnaireURL, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
        webView = WebView(request: request)
    }
    
    var body: some View {
        ZStack {
            webView
                .onNavigateToURL { url in
                    guard let host = url.host, host != "www.surveymonkey.co.uk" else { return }
                    finishClosure()
                }
                .onNavigate { isStart in
                    showLoading = isStart
                }
            if showLoading {
                LoadingView()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

extension QuestionnaireView {
    func onFinished(perform action: @escaping() -> Void) -> Self {
        var copy = self
        copy.finishClosure = action
        return copy
    }
}

struct QuestionnaireView_Previews: PreviewProvider {
    static var previews: some View {
        QuestionnaireView(viewModel: PreProcessViewModel.mock)
    }
}
