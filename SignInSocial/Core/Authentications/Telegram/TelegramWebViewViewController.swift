//
//  TelegramWebViewViewController.swift
//  SignInSocial
//
//  Created by P. Nam on 08/07/2024.
//

import Foundation
import WebKit
import UIKit
import SafariServices

public class TelegramWebViewViewController: UIViewController {
    private let jsonDecoder = JSONDecoder()
    
    private var webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.processPool = WKProcessPool()
        webConfiguration.websiteDataStore = WKWebsiteDataStore.nonPersistent()
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15"
        return webView
    }()
    
    private let completion: (Result<TelegramResultModel?, Error>) -> Void
    
    init(completion: @escaping (Result<TelegramResultModel?, Error>) -> Void) {
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .formSheet
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        completion(.success(nil))
    }
    
    private func visualize() {
        view.addSubview(webView)
        
        let request = URLRequest(
            url: URL(string: "http://m-vio68-dev.huula.dev/request-telegram")!,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
            timeoutInterval: 30
        )
        webView.load(request)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.uiDelegate = self
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])
        view.backgroundColor = .white
        
        let contentController = self.webView.configuration.userContentController
        contentController.add(self, name: "REQUEST_NATIVE")
    }
    
    func createNewWebView(_ config: WKWebViewConfiguration) -> WKWebView {
        let newWebView = WKWebView(frame: webView.frame,
                                   configuration: config)
        newWebView.navigationDelegate = self
        newWebView.uiDelegate = self
        newWebView.allowsBackForwardNavigationGestures = true
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.processPool = WKProcessPool()
        webConfiguration.websiteDataStore = WKWebsiteDataStore.nonPersistent()
        view.addSubview(newWebView)
        newWebView.bounds = view.bounds
        return newWebView
    }
    
    private func getTgAuthResult(from url: URL) -> String? {
        if let parameters = url.fragmentParameters, let tgAuthResult = parameters["tgAuthResult"] {
            return tgAuthResult
        }
        return nil
    }
}

extension TelegramWebViewViewController: WKUIDelegate {
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            let newWebview = createNewWebView(configuration)
            var request = navigationAction.request
            request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData

            webView.load(request)
            return newWebview
        }
        return nil
    }
}

extension TelegramWebViewViewController: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
        preferences.allowsContentJavaScript = true
        
        decisionHandler(.allow, preferences)
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        guard let url = navigationResponse.response.url else {
            decisionHandler(.cancel)
            return
        }
        
        if let host = url.host {
            if host == "m-vio68-dev.huula.dev", let url = webView.url, let base64Encoded = getTgAuthResult(from: url), let decodedData = Data(base64Encoded: base64Encoded), let jsonString = String(data: decodedData, encoding: .utf8), let jsonData = jsonString.data(using: .utf8) {
                do {
                    let user = try jsonDecoder.decode(TelegramResultModel.self, from: jsonData)
                    completion(.success(user))
                    decisionHandler(.cancel)
                    dismiss(animated: true)
                } catch {
                    completion(.failure(error))
                    dismiss(animated: true)
                }
                return
            }
        }
        
        decisionHandler(.allow)
    }
}
    
extension TelegramWebViewViewController: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
//        guard let dict = message.body as? String else {
//            return
//        }
    }
}

public extension URL {
    var queryParameters: [String: String]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems else {
            return nil
        }
        var parameters = [String: String]()
        for queryItem in queryItems {
            parameters[queryItem.name] = queryItem.value
        }
        return parameters
    }
    
    var fragmentParameters: [String: String]? {
        guard let fragment = self.fragment else { return nil }
        var parameters = [String: String]()
        let components = fragment.components(separatedBy: "&")
        for component in components {
            let keyValue = component.components(separatedBy: "=")
            if keyValue.count == 2 {
                let key = keyValue[0]
                let value = keyValue[1]
                parameters[key] = value
            }
        }
        return parameters
    }
}
