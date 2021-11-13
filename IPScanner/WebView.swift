//
//  WebView.swift
//  IPScanner
//
//  Created by Timothy Sonner on 11/10/21.
//

import WebKit
import SwiftUI

struct WebView: UIViewRepresentable {
    let url: String
    let configuration = WKWebViewConfiguration()
    
    // func makeUIView is necessary for conformance to UIViewRepresentable
    func makeUIView(context: Context) -> WKWebView {
        configuration.websiteDataStore = .nonPersistent()
        // URL string method:
        //        guard let url = URL(string: self.url) else {
        //            return WKWebView()
        //        }
        //        let request = URLRequest(url: url)
        //        let wkWebView = WKWebView(frame: .zero, configuration: configuration)
        //        wkWebView.load(request)
        //        return wkWebView
        
        // HTML String method:
        let wkWebView = WKWebView(frame: .zero, configuration: configuration)
        wkWebView.allowsBackForwardNavigationGestures = true

        return wkWebView
        
        //  Straight return method (without declaring wkWebView)
        //        return WKWebView(frame: .zero, configuration: configuration)
    }
    // func updateUIView is necessary for conformance to UIViewRepresentable
    func updateUIView(_ webView: WKWebView, context: Context) {
        // HTML String method using straight return from makeUIView
                webView.loadHTMLString(url, baseURL: nil)
    }
}


struct WebView_Previews: PreviewProvider {
    static var previews: some View {
        WebView(url: "<html><body><h1>Hello Foo!</h1></body></html>")
    }
}
