//
//  ViewController.swift
//  WebKitSample
//
//  Created by Manjunath Shivakumara on 23/02/18.
//  Copyright © 2018 Manjunath Shivakumara. All rights reserved.
//

import UIKit
import WebKit
import JavaScriptCore

var myContext = 0
var jsContext: JSContext!

class ViewController: UIViewController, WKNavigationDelegate {

    weak var webView: WKWebView?
    @IBOutlet weak var webPlaceHolderView: UIView?
    weak var webProgressView: ProgressView?
    @IBOutlet weak var backBarButton: UIBarButtonItem!
    @IBOutlet weak var forwardBarButton: UIBarButtonItem!
    @IBOutlet weak var stopBarButton: UIBarButtonItem!
    @IBOutlet weak var refreshBarButton: UIBarButtonItem!
    
    deinit {
        webView?.removeObserver(self, forKeyPath: "loading")
        webView?.removeObserver(self, forKeyPath: "title")
        webView?.removeObserver(self, forKeyPath: "estimatedProgress")
        webView?.removeObserver(self, forKeyPath: "canGoBack")
        webView?.removeObserver(self, forKeyPath: "canGoForward")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let webViewConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: (webPlaceHolderView?.bounds)!, configuration: webViewConfiguration)
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.addObserver(self, forKeyPath: "loading", options: .new, context: &myContext)
        webView.addObserver(self, forKeyPath: "title", options: .new, context: &myContext)
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: &myContext)
        webView.addObserver(self, forKeyPath: "canGoBack", options: .new, context: &myContext)
        webView.addObserver(self, forKeyPath: "canGoForward", options: .new, context: &myContext)
        self.webPlaceHolderView?.addSubview(webView)
        self.webView = webView
        
        
        let navigationBarBounds = navigationController?.navigationBar.bounds
        let progressView = ProgressView(frame: CGRect(x: 0, y: navigationBarBounds!.size.height - 2, width: navigationBarBounds!.size.width, height: 2))
        progressView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        navigationController?.navigationBar.addSubview(progressView)
        self.webProgressView = progressView
        
        let urlpath     = Bundle.main.path(forResource: "index", ofType: "html")
        let url:URL   = URL.init(fileURLWithPath: urlpath!)
//        let htmlFile = url.lastPathComponent
//        let serverAddress = "http://127.0.0.1:8080/" + htmlFile
//        let urlToHit : URL  = URL.init(string: serverAddress)!
        
        webView.load(URLRequest(url: url))
        
        backBarButton.isEnabled = false
        forwardBarButton.isEnabled = false
        
        
    }

    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let change = change else { return }
        if context != &myContext {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        if keyPath == "loading" {
            if let loading = (change[NSKeyValueChangeKey.newKey] as AnyObject).boolValue {
                stopBarButton?.isEnabled = loading
                refreshBarButton?.isEnabled = !loading
            }
            return
        }
        
        if keyPath == "title" {
            if let title = change[NSKeyValueChangeKey.newKey] as? String {
                navigationItem.title = title
            }
            return
        }
        
        if keyPath == "estimatedProgress" {
            if let progress = (change[NSKeyValueChangeKey.newKey] as AnyObject).floatValue {
                webProgressView?.setProgress(progress, animated: true)
            }
            return
        }
        
        if keyPath == "canGoBack" {
            if let canGoBack = (change[NSKeyValueChangeKey.newKey] as AnyObject).boolValue {
                backBarButton.isEnabled = canGoBack
            }
            return
        }
        
        if keyPath == "canGoForward" {
            if let canGoForward = (change[NSKeyValueChangeKey.newKey] as AnyObject).boolValue {
                forwardBarButton.isEnabled = canGoForward
            }
            return
        }
    }
    
    @IBAction func backBarButtonTapped(_ sender: AnyObject) {
        if webView!.canGoBack {
            webView!.goBack()
        }
    }
    
    @IBAction func forwardBarButtonTapped(_ sender: AnyObject) {
        if webView!.canGoForward {
            webView!.goForward()
        }
    }
    
    @IBAction func stopBarButtonTapped(_ sender: AnyObject) {
        if webView!.isLoading {
            webView!.stopLoading()
        }
    }
    
    @IBAction func refreshBarButtonTapped(_ sender: AnyObject) {
        _ = webView?.reload()
    }
    
    // MARK: - WKNavigationDelegate methods
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation) {
        print("webView:\(webView) didStartProvisionalNavigation:\(navigation)")
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation) {
        print("webView:\(webView) didCommitNavigation:\(navigation)")
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: (@escaping (WKNavigationActionPolicy) -> Void)) {
        print("webView:\(webView) decidePolicyForNavigationAction:\(navigationAction) decisionHandler:\(decisionHandler)")
        
        switch navigationAction.navigationType {
        case .linkActivated:
            if navigationAction.targetFrame == nil {
                webView.load(navigationAction.request)
            }
        default:
            break
        }
        
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: (@escaping (WKNavigationResponsePolicy) -> Void)) {
        print("webView:\(webView) decidePolicyForNavigationResponse:\(navigationResponse) decisionHandler:\(decisionHandler)")
        
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        print("webView:\(webView) didReceiveAuthenticationChallenge:\(challenge) completionHandler:\(completionHandler)")
        
        switch (challenge.protectionSpace.authenticationMethod) {
        case NSURLAuthenticationMethodHTTPBasic:
            let alertController = UIAlertController(title: "Authentication Required", message: webView.url?.host, preferredStyle: .alert)
            weak var usernameTextField: UITextField!
            alertController.addTextField { textField in
                textField.placeholder = "Username"
                usernameTextField = textField
            }
            weak var passwordTextField: UITextField!
            alertController.addTextField { textField in
                textField.placeholder = "Password"
                textField.isSecureTextEntry = true
                passwordTextField = textField
            }
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
                completionHandler(.cancelAuthenticationChallenge, nil)
            }))
            alertController.addAction(UIAlertAction(title: "Log In", style: .default, handler: { action in
                guard let username = usernameTextField.text, let password = passwordTextField.text else {
                    completionHandler(.rejectProtectionSpace, nil)
                    return
                }
                let credential = URLCredential(user: username, password: password, persistence: URLCredential.Persistence.forSession)
                completionHandler(.useCredential, credential)
            }))
            present(alertController, animated: true, completion: nil)
        default:
            completionHandler(.rejectProtectionSpace, nil);
        }
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation) {
        print("webView:\(webView) didReceiveServerRedirectForProvisionalNavigation:\(navigation)")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {
        print("webView:\(webView) didFinishNavigation:\(navigation)")
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation, withError error: Error) {
        print("webView:\(webView) didFailNavigation:\(navigation) withError:\(error)")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation, withError error: Error) {
        print("webView:\(webView) didFailProvisionalNavigation:\(navigation) withError:\(error)")
    }
    
}

