//
//  WKHistoryController.swift
//  AllMarket
//
//  Created by 김민주 on 2017. 9. 22..
//  Copyright © 2017년 MinJu. All rights reserved.
//

import UIKit
import WebKit
import SWSegmentedControl

class WKHistoryController: UIViewController, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler, SWSegmentedControlDelegate {
    
    @IBOutlet weak var guideView: UIView!
    @IBOutlet weak var backBtn: UIBarButtonItem!
    
    var wkWebView = WKWebView()
    var refresher: UIRefreshControl!
    var activityIndicator = UIActivityIndicatorView()
    
    let user_idx = UserDefaults.standard.object(forKey: "user_idx") as! String
    let language = UserDefaults.standard.object(forKey: "selectLanguageEng") as! String
    
    var sc = SWSegmentedControl()
    
    override func viewDidLoad() {
        clearCache()
        settingWebView(url: domain + saleHistoryURL)
        self.addRefreshControl()
    }
    
    override func loadView() {
        super.loadView()
        
        navigationTitle(self, "historyTitle".localized)
        sc = SWSegmentedControl(items: ["saleItem".localized, "evnetTitle".localized])
        
        backBtn.image = UIImage(named:"backBtn")?.withRenderingMode(.alwaysOriginal)
        
        let controller = WKUserContentController()
        controller.add(self, name: "startProductActivity")
        controller.add(self, name: "startEventInfoActivity")
        
        let configuration = WKWebViewConfiguration()
        configuration.processPool = session.processPool
        configuration.userContentController = controller
        
        wkWebView = WKWebView(frame: self.guideView.frame, configuration: configuration)
        
        wkWebView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        wkWebView.scrollView.isScrollEnabled = true
        wkWebView.scrollView.bounces = true
        wkWebView.uiDelegate = self
        wkWebView.navigationDelegate = self
        
        self.guideView.addSubview(wkWebView)
        
        let width = view.frame.size.width
        
        sc.frame = CGRect(x: 0, y: 0, width: width, height: 35)
        segmentedColor(sc)
        sc.delegate = self
        self.view.addSubview(sc)
    }
    
    func settingWebView(url: String) {
        
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
        if message.name == "startEventInfoActivity" {
            let message = message.body as! [String]
            let url = message[0]
            let idx = message[1]
            
            UserDefaults.standard.set(url, forKey: "EventDetailURL")
            UserDefaults.standard.set(idx, forKey: "EventDetailIdx")
            
            print("message: \(message)")
            print("url: \(url)")
            print("idx: \(idx)")
            
//            changeView(target: self, identifier: "EventDetail")
            let EventDetail = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EventDetail") as! WKEventDetailController
            self.navigationController?.pushViewController(EventDetail, animated: true)
        }
        if message.name == "callbackHandler" {
            let message = message.body as! String
            print("message: \(message)")
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
    
    func segmentedControl(_ control: SWSegmentedControl, canSelectItemAtIndex index: Int) -> Bool {
        if index == 0 {
            //판매상품
            print("판매상품")
            
            settingWebView(url: domain + saleHistoryURL)
        } else if index == 1 {
            //이벤트
            print("이벤트")
            
            settingWebView(url: domain + eventHistoryURL)
            
        }
        return true
    }

    @IBAction func DoneBtn(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
