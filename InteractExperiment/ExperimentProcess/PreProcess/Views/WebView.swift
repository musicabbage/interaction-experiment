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
        var navigationBlock: (Bool) -> Void = { _ in }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
            if let url = navigationResponse.response.url {
                print(url)
                urlNavigationBlock(url)
            }
            decisionHandler(.allow)
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            print("didStartProvisionalNavigation")
            navigationBlock(true)
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            navigationBlock(false)
        }
    }
    
    func onNavigateToURL(perform action: @escaping(URL) -> Void) -> Self {
        coordinator.urlNavigationBlock = action
        return self
    }
    
    func onNavigate(perform action: @escaping(Bool) -> Void) -> Self {
        coordinator.navigationBlock = action
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
