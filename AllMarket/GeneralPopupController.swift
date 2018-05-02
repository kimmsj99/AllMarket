//
//  Translate   GeneralPopupController.swift
//  AllMarket
//
//  Created by 김민주 on 2017. 9. 22..
//  Copyright © 2017년 MinJu. All rights reserved.
//

import UIKit
import WebKit

class GeneralPopupController: UIViewController, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {
    
    @IBOutlet weak var backBtn: UIBarButtonItem!
    
    let myData = UserDefaults.standard
    
    var wkWebView = WKWebView()
    
    let user_idx = UserDefaults.standard.object(forKey: "user_idx") as! String
    let language = UserDefaults.standard.object(forKey: "selectLanguageEng") as! String
    
    let generalTitle = UserDefaults.standard.object(forKey: "GeneralText") as! String
    let generalURL = UserDefaults.standard.object(forKey: "GeneralURL") as! String
    
    override func viewDidLoad() {
        settingWebView()
    }
    
    override func loadView() {
        super.loadView()
        navigationTitle(self, generalTitle)
        
        backBtn.image = UIImage(named:"backBtn")?.withRenderingMode(.alwaysOriginal)
        
        let controller = WKUserContentController()
        controller.add(self, name: "startProfileHome")
        controller.add(self, name: "startReload")
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = controller
        
        wkWebView = WKWebView(frame: self.view.frame, configuration: configuration)
        
        wkWebView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        wkWebView.scrollView.isScrollEnabled = true
        wkWebView.scrollView.bounces = true
        wkWebView.uiDelegate = self
        wkWebView.navigationDelegate = self
        
//        var request = URLRequest(url: URL(string: domain + generalURL)!)
//        request.httpMethod = "POST"
//        let postString = "&user_idx=\(user_idx)" + "&lang=\(language)"
//        request.httpBody = postString.data(using: .utf8)
//
//        wkWebView.load(request)
        self.view.addSubview(wkWebView)
    }
    
    func settingWebView() {
        
        let javascriptPOSTRedirect: String = "" +
            "var form = document.createElement('form');" +
            "form.method = 'POST';" +
            "form.action = '\(generalURL)';" +
            "" +
            "var input = document.createElement('input');" +
            "input.type = 'text';" +
            "input.name = 'me';" +
            "input.value = '\(user_idx)';" +
            "form.appendChild(input);" +
            "var input = document.createElement('input');" +
            "input.type = 'text';" +
            "input.name = 'lang';" +
            "input.value = '\(language)';" +
            "form.appendChild(input);" +
            "" +
        "form.submit();"
        //        print(javascriptPOSTRedirect)
        
        wkWebView.evaluateJavaScript(javascriptPOSTRedirect, completionHandler: nil)
        
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "startProfileHome" {
            let idx = message.body as! String
            print("idx: \(idx)")
            
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
        if message.name == "startReload" {
            let scriptmessage = message.body as! String
            print("scriptmessage : \(scriptmessage)")
            
            wkWebView.reload()
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
    
    @IBAction func DoneBtn(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
