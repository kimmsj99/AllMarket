//
//  EventDetailController.swift
//  AllMarket
//
//  Created by 김민주 on 2017. 9. 22..
//  Copyright © 2017년 MinJu. All rights reserved.
//

import UIKit
import WebKit

class WKEventDetailController: UIViewController, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {
    
    @IBOutlet weak var backBtn: UIBarButtonItem!
    
    var wkWebView = WKWebView()
    var activityIndicator = UIActivityIndicatorView()
    
    let user_idx = UserDefaults.standard.object(forKey: "user_idx") as! String
    let language = UserDefaults.standard.object(forKey: "selectLanguageEng") as! String
    
    override func viewDidLoad() {
        clearCache()
        settingWebView()
        self.addRefreshControl()
    }
    
    override func loadView() {
        super.loadView()
        
        navigationTitle(self, "eventDetail".localized)
        
        self.tabBarController?.tabBar.isHidden = true
        
        backBtn.image = UIImage(named:"backBtn")?.withRenderingMode(.alwaysOriginal)
        
        let controller = WKUserContentController()
        controller.add(self, name: "startProfileHome")
        
        let configuration = WKWebViewConfiguration()
        configuration.processPool = session.processPool
        configuration.userContentController = controller
        
        wkWebView = WKWebView(frame: self.view.frame, configuration: configuration)
        
        wkWebView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        wkWebView.scrollView.isScrollEnabled = true
        wkWebView.scrollView.bounces = true
        wkWebView.uiDelegate = self
        wkWebView.navigationDelegate = self
        
        self.view.addSubview(wkWebView)
    }
    
    func settingWebView() {
        
        var url = ""
        
        if UserDefaults.standard.object(forKey: "edURL") == nil {
            
            if UserDefaults.standard.object(forKey: "EventUrl") == nil {
                
                let EventDetailURL = UserDefaults.standard.object(forKey: "EventDetailURL") as! String
                let EventDetailIdx = UserDefaults.standard.object(forKey: "EventDetailIdx") as! String
                
                url = domain + EventDetailURL + "/" + EventDetailIdx
            } else {
                let eventUrl = UserDefaults.standard.object(forKey: "EventUrl") as! String
                url = domain + eventUrl
            }
            
        } else {
            let eventDetailUrl = UserDefaults.standard.object(forKey: "edURL") as! String
            url = domain + eventDetailUrl
        }
        
        let javascriptPOSTRedirect: String = "" +
            "var form = document.createElement('form');" +
            "form.method = 'POST';" +
            "form.action = '\(url)';" +
            "" +
            "var input = document.createElement('input');" +
            "input.type = 'text';" +
            "input.name = 'me';" +
            "input.value = '\(user_idx)';" +
            "form.appendChild(input);" +
            "var input = document.createElement('input');" +
            "input.type = 'text';" +
            "input.name = 'lang';" +
            "input.value = '\(self.language)';" +
            "form.appendChild(input);" +
            "" +
        "form.submit();"
        //        print(javascriptPOSTRedirect)
        
        wkWebView.evaluateJavaScript(javascriptPOSTRedirect, completionHandler: nil)
        
    }
    
    func addRefreshControl(){
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshWebView(_:)), for: .valueChanged)
        wkWebView.scrollView.addSubview(refreshControl)
    }
    
    func refreshWebView(_ sender: UIRefreshControl) {
        wkWebView.reload()
        sender.endRefreshing()
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        if message.name == "startProfileHome" {
            let idx = message.body as! String
            print("idx: \(idx)")
            
            if idx == user_idx {
                
                changeView(target: self, identifier: "ProfileHome")
                
            } else {
                UserDefaults.standard.set(idx, forKey: "idx")
                changeView(target: self, identifier: "UserProfile")
            }
        }
        
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let otherAction = UIAlertAction(title: "okTitle".localized, style: .default) {
            action in completionHandler()
        }
        alertController.addAction(otherAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "cancelTitle".localized, style: .cancel) {
            action in completionHandler(false)
        }
        let okAction = UIAlertAction(title: "okTitle".localized, style: .default) {
            action in completionHandler(true)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alertController = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)
        let okHandler: () -> Void = { handler in
            if let textField = alertController.textFields?.first {
                completionHandler(textField.text)
            } else {
                completionHandler("")
            }
        }
        let cancelAction = UIAlertAction(title: "cancelTitle".localized, style: .cancel) {
            action in completionHandler(nil)
        }
        let okAction = UIAlertAction(title: "okTitle".localized, style: .default) {
            action in okHandler()
        }
        alertController.addTextField { $0.text = defaultText }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
//        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
//        activityIndicator.frame = CGRect(x: view.frame.midX - 25, y: view.frame.midY - 25 - 64 , width: 50, height: 50)
//        activityIndicator.hidesWhenStopped = true
//        activityIndicator.startAnimating()
//        
//        view.addSubview(activityIndicator)
        
        // 2. 상단 status bar에도 activity indicator가 나오게 할 것이다.
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.activityIndicator.removeFromSuperview()
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
    }

    @IBAction func DoneBtn(_ sender: UIBarButtonItem) {
        self.tabBarController?.tabBar.isHidden = false
        UserDefaults.standard.removeObject(forKey: "edURL")
        if UserDefaults.standard.object(forKey: "EventUrl") != nil {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
        UserDefaults.standard.removeObject(forKey: "EventUrl")
    }
    
}
