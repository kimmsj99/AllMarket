//
//  WKFilteringController.swift
//  AllMarket
//
//  Created by 김민주 on 2017. 10. 10..
//  Copyright © 2017년 MinJu. All rights reserved.
//

import UIKit
import WebKit

class WKFilteringController: UIViewController, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler, UIScrollViewDelegate {

    let user_idx = UserDefaults.standard.object(forKey: "user_idx") as! String
    let language = UserDefaults.standard.object(forKey: "selectLanguageEng") as! String
    
    var wkWebView = WKWebView()
    var refresher: UIRefreshControl!
    
    var resetBtn: UIBarButtonItem!
    
    override func viewWillAppear(_ animated: Bool) {
        clearCache()
    }
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.backItem?.title = ""
        clearCache()
        settingWebView()
    }
    
    override func loadView() {
        super.loadView()
        
        navigationTitle(self, "filteringTitle".localized)
        
        navigationItem.leftBarButtonItems = CustomBackButton.createWithImage(view: self.view, image: #imageLiteral(resourceName: "backBtn"), color: .white, target: self, action: #selector(DoneBtn(_:)))
        
        let controller = WKUserContentController()
        let userScript = WKUserScript(source: "selectFinish()", injectionTime: .atDocumentStart, forMainFrameOnly: true)
        
        resetBtn = UIBarButtonItem(title: "resetTitle".localized, style: .plain, target: self, action: #selector(resetAction(_:)))
        resetBtn.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem = resetBtn
        
        controller.addUserScript(userScript)
        controller.add(self, name: "setMenu")
        controller.add(self, name: "categorySelect")
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = controller
        
        wkWebView = WKWebView(frame: self.view.frame, configuration: configuration)
        
        wkWebView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        wkWebView.scrollView.isScrollEnabled = true
        wkWebView.scrollView.bounces = true
        wkWebView.uiDelegate = self
        wkWebView.navigationDelegate = self
        wkWebView.scrollView.delegate = self
        wkWebView.scrollView.isScrollEnabled = false
        
        self.view.addSubview(wkWebView)
    }
    
    func settingWebView() {
        
        var url: String
        var searchRes: String
        var filterRes: String
        
        UserDefaults.standard.set("null", forKey: "filterRes")

        if UserDefaults.standard.object(forKey: "keyword") != nil {
            let keyword = UserDefaults.standard.object(forKey: "keyword") as! String
            UserDefaults.standard.set(keyword, forKey: "searchRes")
            
            searchRes = UserDefaults.standard.object(forKey: "searchRes") as! String
            filterRes = UserDefaults.standard.object(forKey: "filterRes") as! String
            
            url = domain + filteringURL + "/1/\(searchRes)/\(filterRes)"
        } else {
            UserDefaults.standard.set("null", forKey: "searchRes")
            
            let category = UserDefaults.standard.object(forKey: "Category") as! String
            searchRes = UserDefaults.standard.object(forKey: "searchRes") as! String
            filterRes = UserDefaults.standard.object(forKey: "filterRes") as! String
            
            url = domain + filteringURL + "/\(category)/\(searchRes)/\(filterRes)"
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
            "input.value = '\(language)';" +
            "form.appendChild(input);" +
            "" +
        "form.submit();"
//        print(javascriptPOSTRedirect)
        
        wkWebView.evaluateJavaScript(javascriptPOSTRedirect, completionHandler: nil)
        
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "setMenu" {
            let message = message.body as! [String]
            let apply = message[0]
            let searchRes = message[1]
            let filterRes = message[2]
            
            UserDefaults.standard.set(searchRes, forKey: "searchRes")
            UserDefaults.standard.set(filterRes, forKey: "filterRes")
            
            print("filter message : \(message)")
            
            if apply == "item" {
                self.navigationController?.popViewController(animated: true)
            }
        }
        
        if message.name == "categorySelect" {
            let message = message.body as! String
            
            print("CategorySelect Message : \(message)")
            
            if message == "true"{
                
                self.navigationItem.rightBarButtonItem = nil
                navigationItem.leftBarButtonItems = CustomBackButton.createWithImage(view: self.view, image: #imageLiteral(resourceName: "backBtn"), color: .white, target: self, action: #selector(goBack(_:)))
                print("webview backbutton : \(self.view.frame.width)")
                print("webview backbutton : \(self.view.frame.height)")
                
            } else {
                
                resetBtn = UIBarButtonItem(title: "resetTitle".localized, style: .plain, target: self, action: #selector(resetAction(_:)))
                resetBtn.tintColor = UIColor.white
                self.navigationItem.rightBarButtonItem = resetBtn
                
                navigationItem.leftBarButtonItems = CustomBackButton.createWithImage(view: self.view, image: #imageLiteral(resourceName: "backBtn"), color: .white, target: self, action: #selector(DoneBtn(_:)))
                
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func goBack(_ sender: UIBarButtonItem) {
        wkWebView.evaluateJavaScript("selectFinish()", completionHandler: { (result, error) in
            if let result = result {
                print("result : \(result)")
            }
            
        })
    }
    
    func resetAction(_ sender: UIBarButtonItem) {
        wkWebView.reload()
    }
    
    func DoneBtn(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil
    }
    
}
