//
//  WebView.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/7/18.
//

import SwiftUI
import WebKit


struct WebView: UIViewRepresentable {
    
    let request: URLRequest
    let coordinator: Coordinator = .init()
    
    init(request: URLRequest) {
        self.request = request
    }
    
    init(url: URL) {
        self.init(request: URLRequest(url: url))
    }
    
    func makeCoordinator() -> Coordinator {
        coordinator
    }
    
    func makeUIView(context: Context) -> WKWebView {
        WKWebView()
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.load(request)
        webView.navigationDelegate = context.coordinator
    }
}

extension WebView {
    class Coordinator: NSObject, WKNavigationDelegate {
        
        var urlNavigationBlock: (URL) -> Void = { _ in }
        var navigationFinishedBlock: () -> Void = { }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
            if let url = navigationResponse.response.url {
                urlNavigationBlock(url)
            }
            decisionHandler(.allow)
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            navigationFinishedBlock()
        }
    }
    
    func onNavigateToURL(perform action: @escaping(URL) -> Void) -> Self {
        self.coordinator.urlNavigationBlock = action
        return self
    }
    
    func onNavigateFinished(perform action: @escaping() -> Void) -> Self {
        self.coordinator.navigationFinishedBlock = action
        return self
    }
    
    static func cleanAllCache() {
        //https://stackoverflow.com/a/35298652
        URLCache.shared.removeAllCachedResponses()
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        print("[WebCacheCleaner] All cookies deleted")
        
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                print("[WebCacheCleaner] Record \(record) deleted")
            }
        }
    }
}

struct WebView_Previews: PreviewProvider {
    static var previews: some View {
        WebView(url: Bundle.main.url(forResource: "consent_form", withExtension: "pdf")!)
    }
}
