//
//  WKHomeController.swift
//  AllMarket
//
//  Created by 김민주 on 2017. 9. 21..
//  Copyright © 2017년 MinJu. All rights reserved.
//

import UIKit
import WebKit
import Alamofire

class WKHomeController: UIViewController, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {

    @IBOutlet weak var guideView: UIView!
    
    var wkWebView = WKWebView()
    var refresher: UIRefreshControl!
    var activityIndicator = UIActivityIndicatorView()
    
    let user_idx = UserDefaults.standard.object(forKey: "user_idx") as! String
    let language = UserDefaults.standard.object(forKey: "selectLanguageEng") as! String
    
    let myData : UserDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        
        myData.removeObject(forKey: "keyword")
        myData.removeObject(forKey: "searchRes")
        myData.removeObject(forKey: "filterRes")
        myData.removeObject(forKey: "ItemInfoIdx")
        
        //경고회원 alert
        if myData.object(forKey: "blackMem") != nil{
            let warnig = myData.object(forKey: "blackMem") as! String
            if warnig == "true" {
                if myData.object(forKey: "alert") == nil{
                    basicAlert(target: self, title: nil, message: "warningMem".localized)
                    myData.set("경고회원", forKey: "alert")
                }
            }
        }
        
        settingWebView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        myData.removeObject(forKey: "keyword")
        myData.removeObject(forKey: "searchRes")
        myData.removeObject(forKey: "filterRes")
        myData.removeObject(forKey: "ItemInfoIdx")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if let token = myData.object(forKey: "token") {
            if (myData.object(forKey: "email") != nil && (myData.object(forKey: "pass") != nil)) {
                let email = myData.object(forKey: "email") as! String
                let passwd = myData.object(forKey: "pass") as! String
                
                let parameter = ["email":email,
                                 "pw":passwd,
                                 "lang":language,
                                 "token":token,
                                 "device":"1"]
                
                Alamofire.request(domain + loginURL,
                                  method: .post,
                                  parameters: parameter,
                                  encoding: URLEncoding.default,
                                  headers: nil).response(completionHandler: { (response) in
                                    self.parseLogin(JSONData: response.data!)
                                  })
                
                
            }
        }
    }
    
    override func loadView() {
        super.loadView()
        
        if UserDefaults.standard.string(forKey: "idx") != nil {
            UserDefaults.standard.removeObject(forKey: "idx")
        } else {
            UserDefaults.standard.removeObject(forKey: "idx")
        }
        
        let controller = WKUserContentController()
        
        controller.add(self, name: "startRandomActivity")       //일반팝업
        controller.add(self, name: "startEventInfoActivity")    //이벤트팝업
        controller.add(self, name: "startProductAddActivity")   //상품등록
        controller.add(self, name: "startHistoryActivity")      //히스토리
        controller.add(self, name: "startHomeProductActivity")  //키워드
        controller.add(self, name: "startHomeProductActivity2") //키워드
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = controller
        
        wkWebView = WKWebView(frame: self.guideView.frame, configuration: configuration)
        
        wkWebView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        wkWebView.scrollView.isScrollEnabled = true
        wkWebView.scrollView.bounces = true
        wkWebView.uiDelegate = self
        wkWebView.navigationDelegate = self
    
        self.guideView.addSubview(wkWebView)
    }
    
    func settingWebView() {
        
        let javascriptPOSTRedirect: String = "" +
            "var form = document.createElement('form');" +
            "form.method = 'POST';" +
            "form.action = '\(domain + homeURL)';" +
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
        addRefreshControl()
    }
    
    func addRefreshControl() {
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(refreshWebView), for: .valueChanged)
        
        wkWebView.scrollView.addSubview(refresher)
    }
    
    func refreshWebView() {
        wkWebView.reload()
        refresher.endRefreshing()
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "startRandomActivity" {
            let message = message.body as! [String]
            let url = message[0]
            let text = message[1]
            
            print("message: \(message)")
            print("url: \(url)")
            print("text: \(text)")
            
            UserDefaults.standard.set(url, forKey: "GeneralURL")
            UserDefaults.standard.set(text, forKey: "GeneralText")
            
            changeView(target: self, identifier: "GeneralPopup")
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
            
            changeView(target: self, identifier: "EventDetail")
        }
        if message.name == "startProductAddActivity" {
            let scriptMessage = message.body as! String
            print("scriptMessage: \(scriptMessage)")
            
            changeView(target: self, identifier: "ItemRegist")
            
        }
        if message.name == "startHistoryActivity" {
            let scriptMessage = message.body as! String
            print("scriptMessage: \(scriptMessage)")
            
            changeView(target: self, identifier: "History")
        }
        if message.name == "startHomeProductActivity" {
            let url = message.body as! String
            print("url : \(url)")
            
            myData.removeObject(forKey: "bestLink")
            UserDefaults.standard.set(url, forKey: "keywordURL")
            changeView(target: self, identifier: "ItemSearch")
        }
        
        if message.name == "startHomeProductActivity2" {
            let title = message.body as! String
            print("title : \(title)")
            
            UserDefaults.standard.set(title, forKey: "keyword")
            changeView(target: self, identifier: "ItemSearch")
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
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        activityIndicator.frame = CGRect(x: view.frame.midX - 25, y: view.frame.midY - 25, width: 50, height: 50)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        
        view.addSubview(activityIndicator)
        
        // 2. 상단 status bar에도 activity indicator가 나오게 할 것이다.
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.activityIndicator.removeFromSuperview()
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
    }
    
    func parseLogin(JSONData: Data) {
        do{
            let readableJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! [String:AnyObject]
            print("JSON : \(readableJSON)")
            
            let loginState = readableJSON["result"] as! String
            
            if loginState == "true" {
                //로그인 성공
                
                myData.set(readableJSON["menu"], forKey: "menu")
                print("@@@@ \(myData.object(forKey: "user_idx")!) @@@@")
                print("@@@@ \(myData.object(forKey: "menu")!) @@@@")
                
            }
            
        }catch{
            print(" error \(error)")
            basicAlert(target: self, title: "로그인 실패", message: "다시 시도해주세요")
        }
    }
    
}
