//
//  WKItemRegistrationController.swift
//  AllMarket
//
//  Created by 김민주 on 2017. 9. 21..
//  Copyright © 2017년 MinJu. All rights reserved.
//

import UIKit
import WebKit
import Alamofire
import SWSegmentedControl
import DKImagePickerController

class WKItemRegistrationController: UIViewController, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate {
    
//    @IBOutlet weak var backBtn: UIBarButtonItem!
    
    let user_idx = UserDefaults.standard.object(forKey: "user_idx") as! String
    let language = UserDefaults.standard.object(forKey: "selectLanguageEng") as! String
    
    var backBtn: UIBarButtonItem!
    var resetBtn: UIBarButtonItem!
    
    var wkWebView = WKWebView()
    var refresher: UIRefreshControl!
    var activityIndicator = UIActivityIndicatorView()
    
    var picker = UIImagePickerController()
    let pickerController = DKImagePickerController()
    
    var imgUrl = ""
    
    var imageData: Data?
    var imageDataArr = [Data]()
    var assets: [DKAsset]?
    
    override func viewDidLoad() {
        clearCache()
        settingWebView()
        
    }
    
    override func loadView() {
        super.loadView()
        
        navigationTitle(self, "itemRegistTitle".localized)
        
//        backBtn.image = UIImage(named:"backBtn")?.withRenderingMode(.alwaysOriginal)
        
        backBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "backBtn"), style: .plain, target: self, action: #selector(DoneBtn(_:)))
        backBtn.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = backBtn
        
        resetBtn = UIBarButtonItem(title: "resetTitle".localized, style: .plain, target: self, action: #selector(resetAction(_:)))
        resetBtn.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem = resetBtn
        
        wkWebView.allowsBackForwardNavigationGestures = true
        
        let controller = WKUserContentController()
        let userScript = WKUserScript(source: "selectFinish()", injectionTime: .atDocumentStart, forMainFrameOnly: true)
        
        controller.addUserScript(userScript)
        controller.add(self, name: "startProductAdd")
        controller.add(self, name: "categorySelect")
        controller.add(self, name: "imageUpload")
        controller.add(self, name: "startProductAddBack")
        
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
        
        let javascriptPOSTRedirect: String = "" +
            "var form = document.createElement('form');" +
            "form.method = 'POST';" +
            "form.action = '\(domain + itemRegistURL)';" +
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
    
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        if message.name == "startProductAdd" {
            let message = message.body as! [String]
            
            print("startProductAdd message : \(message)")
            
            let url = message[0]
            let idx = message[1]
            
            UserDefaults.standard.set(url, forKey: "ItemInfoURL")
            UserDefaults.standard.set(idx, forKey: "ItemInfoIdx")
            
            UserDefaults.standard.set("MyItemRegist", forKey: "MyItemRegist")
            
//            changeView(target: self, identifier: "NaviItemInfo")
            let ItemInfo = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ItemInfo") as? WKItemInfoController
            self.navigationController?.pushViewController(ItemInfo!, animated: true)
        }
        if message.name == "categorySelect" {
            let message = message.body as! String
            
            if message == "true"{
                
                self.navigationItem.rightBarButtonItem = nil
                self.navigationItem.leftBarButtonItem = nil
                backBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "backBtn"), style: .plain, target: self, action: #selector(goBack(_:)))
                backBtn.tintColor = UIColor.white
                self.navigationItem.leftBarButtonItem = backBtn
                
            } else {
                backBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "backBtn"), style: .plain, target: self, action: #selector(DoneBtn(_:)))
                backBtn.tintColor = UIColor.white
                self.navigationItem.leftBarButtonItem = backBtn
                
                resetBtn = UIBarButtonItem(title: "resetTitle".localized, style: .plain, target: self, action: #selector(resetAction(_:)))
                resetBtn.tintColor = UIColor.white
                self.navigationItem.rightBarButtonItem = resetBtn
                
            }
        }
        if message.name == "imageUpload" {
            let message = message.body as! String
            
            if message == "open" {
                
                let alert = UIAlertController(title: "imageUpload".localized, message: nil, preferredStyle: .actionSheet)
                
                let cameraAction = UIAlertAction(title: "openCamera".localized, style: .default) { (action) in
                    self.openCamera()
                    
                }
                
                let galleryAction = UIAlertAction(title: "openAlbum".localized, style: .default) { (action) in
                    self.openPhotoLibrary()
                    
                }
                
                let cancelAction = UIAlertAction(title: "cancelTitle".localized, style: .cancel, handler: nil)
                
                picker.delegate = self
                
                alert.addAction(cameraAction)
                alert.addAction(galleryAction)
                alert.addAction(cancelAction)
                
                self.present(alert, animated: true, completion: nil)
            }
        }
        if message.name == "startProductAddBack"{
            let message = message.body as! String
            
            print("message: \(message)")
            
            if message == "true" {
                let alert = UIAlertController(title: "contentCheck".localized, message: nil, preferredStyle: .alert)

                let okAction = UIAlertAction(title: "okTitle".localized, style: .default){
                    (_) in

//                    self.navigationController?.popViewController(animated: true)
                    self.dismiss(animated: true, completion: nil)

                }

                let cancelAction = UIAlertAction(title: "cancelTitle".localized, style: .cancel)

                alert.addAction(okAction)
                alert.addAction(cancelAction)

                self.present(alert, animated: false, completion: nil)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
        
    }
    
    func openCamera() {
        let pickerController = DKImagePickerController()
        pickerController.sourceType = .camera
        pickerController.didSelectAssets = { [unowned self] (assets: [DKAsset]) in
            print("assets: \(assets)")
            for each in assets {
                each.fetchImageDataForAsset(true, completeBlock: { (data, result) in
                    if let data = data {
                        self.imageDataArr.append(data)
                        
                        self.uploadImages(data)
                    }
                })
            }
        }
        self.present(pickerController, animated: true, completion: nil)
    }
    
    func openPhotoLibrary() {
        let pickerController = DKImagePickerController()
        pickerController.assetType = .allPhotos
        pickerController.showsCancelButton = true
        pickerController.maxSelectableCount = 10
        pickerController.defaultSelectedAssets = self.pickerController.selectedAssets
        pickerController.didSelectAssets = { [unowned self] (assets: [DKAsset]) in
            print("assets: \(assets)")
            for each in assets {
                each.fetchImageDataForAsset(true, completeBlock: { (data, result) in
                    if let data = data {
                        self.imageDataArr.append(data)
                        
                        self.uploadImages(data)
                    }
                })
            }
        }
        
        self.present(pickerController, animated: true, completion: nil)
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
    
    func resetAction(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "resetConfirm".localized, message: nil, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "okTitle".localized, style: .default){
            (_) in
            
            //웹뷰 reload
            self.wkWebView.reload()
        }
        
        let cancelAction = UIAlertAction(title: "cancelTitle".localized, style: .cancel)
        
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        
        self.present(alert, animated: false, completion: nil)
        
    }
    
    func goBack(_ sender: UIBarButtonItem) {
        wkWebView.evaluateJavaScript("selectFinish()", completionHandler: { (result, error) in
            if let result = result {
                print("result : \(result)")
            }
            
        })
    }
    
    func DoneBtn(_ sender: UIBarButtonItem) {
        wkWebView.evaluateJavaScript("writing()", completionHandler: nil)
    }
    
    func updateAssets(assets: [DKAsset]) {
        print("didSelectAssets")
        
        self.assets = assets
    }
    
    func uploadImages(_ data: Data) {
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            
            multipartFormData.append(data, withName: "img[0]", fileName: "image.png", mimeType: "image/png")
            
        }, usingThreshold: UInt64.init(),
           to: domain + imgRegistURL,
           method: .post,
           headers: nil) { (result) in
            switch result{
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    print("Succesfully uploaded")
                    print("response : \(response)")
                    
                    if let img = response.result.value as? [String : Any] {
                        
                        print("new_image : \(img["new_image"])")
                        
                        if let we = img["new_image"] as? [Any] {
                            print((we.first as! [String : String])["src"]!)
                            self.imgUrl = (we.first as! [String: String])["src"]!
                        }
                        
                    }
                    print("imgUrl : \(self.imgUrl)")
                    self.wkWebView.evaluateJavaScript("iosimg('\(self.imgUrl)')", completionHandler: { error, result in
                        if let error = error {
                            print("error : \(error)")
                        } else {
                            print("result : \(result)")
                        }
                    })
                    
                }
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
            }
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil
    }
    
}

