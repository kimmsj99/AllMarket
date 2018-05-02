//
//  WKItemSearchController.swift
//  AllMarket
//
//  Created by 김민주 on 2017. 10. 19..
//  Copyright © 2017년 MinJu. All rights reserved.
//

import UIKit
import WebKit

class WKItemSearchController: UIViewController, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {

    @IBOutlet weak var backBtn: UIBarButtonItem!
    @IBOutlet weak var optionBtn: UIBarButtonItem!
    
    let myData : UserDefaults = UserDefaults.standard
    
    var wkWebView = WKWebView()
    var activityIndicator = UIActivityIndicatorView()
    
    let user_idx = UserDefaults.standard.object(forKey: "user_idx") as! String
    let language = UserDefaults.standard.object(forKey: "selectLanguageEng") as! String
    
    override func viewDidLoad() {
        self.settingWebView()
        self.addRefreshControl()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if myData.object(forKey: "keyword") == nil {
            navigationTitle(self, "")
        } else {
            let keyword : String = myData.string(forKey: "keyword")!
            navigationTitle(self, keyword)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        settingWebView()
    }
    
    override func loadView() {
        super.loadView()
        
        if myData.object(forKey: "keyword") == nil {
            navigationTitle(self, "")
        } else {
            let keyword : String = myData.string(forKey: "keyword")!
            navigationTitle(self, keyword)
        }
        
        backBtn.image = UIImage(named:"backBtn")?.withRenderingMode(.alwaysOriginal)
        optionBtn.image = UIImage(named:"optionBtn")?.withRenderingMode(.alwaysOriginal)
        
        if myData.object(forKey: "keywordURL") != nil {
            navigationItem.rightBarButtonItem = nil
        }
        
        let controller = WKUserContentController()
        controller.add(self, name: "startProductActivity")
        controller.add(self, name: "setMenu")
        
        let configuration = WKWebViewConfiguration()
        configuration.processPool = session.processPool
        configuration.userContentController = controller
        
        wkWebView = WKWebView(frame: self.view.frame, configuration: configuration)

        wkWebView.autoresizingMask = [.flexibleWidth, .flexibleHeight ]
        wkWebView.scrollView.isScrollEnabled = true
        wkWebView.scrollView.bounces = true
        wkWebView.uiDelegate = self
        wkWebView.navigationDelegate = self
        
        self.view.addSubview(wkWebView)
    }
    
    func settingWebView() {
        
        var url = ""
        var filterRes = ""
        
        if myData.object(forKey: "bestLink") != nil{
            let bestLink = myData.object(forKey: "bestLink") as! String
            url = domain + itemResultURL + "/\(bestLink)/"
            
            url.append(myData.object(forKey: "keyword") as! String)
            print("url : \(url)")
            
        } else {
            if myData.object(forKey: "keyword") != nil {
                
                url = domain + itemResultURL + "/1/"
                url.append(myData.object(forKey: "keyword") as! String)
                
                if myData.object(forKey: "filterRes") != nil {
                    filterRes = myData.object(forKey: "filterRes") as! String
                    
                } else {
                    filterRes = "null"
                }
                
                print("url : \(url)")
                
            } else {
                url = myData.object(forKey: "keywordURL") as! String
                print("url : \(url)")
            }
        }
        
        let javascriptPOSTRedirect = "" +
            "var form = document.createElement('form');" +
            "form.method = 'POST';" +
            "" +
            "form.action = '\(url + "/\(filterRes)")';" +
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
        if message.name == "startProductActivity" {
            let message = message.body as! [String]
            let url = message[0]
            let idx = message[1]
            
            UserDefaults.standard.set(url, forKey: "ItemInfoURL")
            UserDefaults.standard.set(idx, forKey: "ItemInfoIdx")
            
//            changeView(target: self, identifier: "ItemInfo")
            let ItemInfo = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ItemInfo") as!  WKItemInfoController
            
            self.navigationController?.pushViewController(ItemInfo, animated: true)
        }
        if message.name == "setMenu" {
            let message = message.body as! [String]
            
            print("setMenu message : \(message)")
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
        myData.removeObject(forKey: "keyword")
        myData.removeObject(forKey: "keywordURL")
        self.dismiss(animated: true, completion: nil)
    }

}
