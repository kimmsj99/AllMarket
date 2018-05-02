//
//  WKMyItemController.swift
//  AllMarket
//
//  Created by 김민주 on 2017. 9. 25..
//  Copyright © 2017년 MinJu. All rights reserved.
//

import UIKit
import WebKit
import Alamofire

class WKMyItemController: UIViewController, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {
    
    @IBOutlet weak var backBtn: UIBarButtonItem!
    
    var wkWebView = WKWebView()
    var activityIndicator = UIActivityIndicatorView()
    
    let user_idx = UserDefaults.standard.object(forKey: "user_idx") as! String
    let language = UserDefaults.standard.object(forKey: "selectLanguageEng") as! String
    
    var cnt: String!
    var temp: String!
    let queue = DispatchQueue(label: "com.cnoon.response-queue", qos: .utility, attributes: [.concurrent])
    
    override func viewDidLoad() {
        self.settingWebView()
        self.addRefreshControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.requestCnt({ [unowned self] in
            self.cnt = self.temp
            if (UserDefaults.standard.object(forKey: "idx") == nil){
                
                navigationTitle(self, "myItemTitle".localized + " (\(self.cnt!))")
                
            } else {
                if (UserDefaults.standard.object(forKey: "user_name") == nil){
                    navigationTitle(self, "myItemTitle".localized + " (\(self.cnt!))")
                } else {
                    let user_name = UserDefaults.standard.object(forKey: "user_name") as! String
                    navigationTitle(self, "\(user_name) (\(self.cnt!))")
                }
            }
        })
        
        print("cnt : \(cnt)")
        wkWebView.reload()
    }
    
    override func loadView() {
        super.loadView()
        
        backBtn.image = UIImage(named:"backBtn")?.withRenderingMode(.alwaysOriginal)
        
        let controller = WKUserContentController()
        controller.add(self, name: "startProductActivity")
        
        let configuration = WKWebViewConfiguration()
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
        
        var itemUserIdx = ""
        
        if (UserDefaults.standard.object(forKey: "idx") == nil){
            itemUserIdx = user_idx
        } else {
            let idx = UserDefaults.standard.object(forKey: "idx") as! String
            itemUserIdx = idx
        }
        
        let javascriptPOSTRedirect: String = "" +
            "var form = document.createElement('form');" +
            "form.method = 'POST';" +
            "form.action = '\(domain + myProductViewURL)';" +
            "" +
            "var input = document.createElement('input');" +
            "input.type = 'text';" +
            "input.name = 'me';" +
            "input.value = '\(itemUserIdx)';" +
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
            
            print("message: \(message)")
            print("url: \(url)")
            print("idx: \(idx)")
            
            if (UserDefaults.standard.object(forKey: "idx") == nil){
                
                UserDefaults.standard.set(url, forKey: "MyItemURL")
                UserDefaults.standard.set(idx, forKey: "MyItemIdx")
                
                let MyItemDetail = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyItemDetail") as! WKMyItemDetailController
                self.navigationController?.pushViewController(MyItemDetail, animated: true)
                
//                changeView(target: self, identifier: "MyItemDetail")
            } else {
//                let idx = UserDefaults.standard.object(forKey: "idx") as! String
                UserDefaults.standard.set(url, forKey: "ItemInfoURL")
                UserDefaults.standard.set(idx, forKey: "ItemInfoIdx")
//                changeView(target: self, identifier: "ItemInfo")
                
                let ItemInfo = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ItemInfo") as! WKItemInfoController
                self.navigationController?.pushViewController(ItemInfo, animated: true)
                
            }
        }
    }
    
    func requestCnt(_ completionHandler : @escaping () -> ()){
        
        var parameter = ["":""]
        
        if (UserDefaults.standard.object(forKey: "idx") == nil){
            parameter = ["user_idx1":user_idx]
        } else {
            let idx = UserDefaults.standard.object(forKey: "idx") as! String
            parameter = ["user_idx1":idx]
        }
        
        print("parameter : \(parameter)")
        
        Alamofire.request(domain + myProductCntURL,
                          method: .post,
                          parameters: parameter, encoding: URLEncoding.default, headers: nil).response(
            queue: queue,
            responseSerializer: DataRequest.jsonResponseSerializer(),
            completionHandler: { (response) in
            do {
                let readableJSON = try JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) as! [String: AnyObject]
                
                print("JSON : \(readableJSON)")
                
                self.temp = readableJSON["myitemCount"] as! String
//                print("cnt : \(self.cnt!)")
                
                DispatchQueue.main.async {
                    completionHandler()
                }
                
            } catch {
                print("MyProductCnt Error : \(error)")
                
            }
        })
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
        self.dismiss(animated: true, completion: nil)
    }
    
}
