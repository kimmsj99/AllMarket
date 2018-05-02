//
//  WKQuestionController.swift
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

class WKQuestionController: UIViewController, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler, UIImagePickerControllerDelegate, UINavigationControllerDelegate, SWSegmentedControlDelegate {

    @IBOutlet weak var backBtn: UIBarButtonItem!
    @IBOutlet weak var guideView: UIView!
    
    var wkWebView = WKWebView()
    var activityIndicator = UIActivityIndicatorView()
    let refreshControl = UIRefreshControl()
    
    var segueUrl = ""
    
    let user_idx = UserDefaults.standard.object(forKey: "user_idx") as! String
    let language = UserDefaults.standard.object(forKey: "selectLanguageEng") as! String
    
    var picker = UIImagePickerController()
    let pickerController = DKImagePickerController()
    let sc = SWSegmentedControl(items: ["Q&A", "contact".localized, "reply".localized])
    
    var imgUrl = ""
    
    var imageData: Data?
    var imageDataArr = [Data]()
    var assets: [DKAsset]?
    
    override func viewDidLoad() {
        if UserDefaults.standard.object(forKey: "questionAlert") != nil {
            sc.setSelectedSegmentIndex(2, animated: true)
            settingWebView(url: answerURL)
        } else {
            settingWebView(url: QandAURL)
        }
        self.addRefreshControl()
    }
    
    override func loadView() {
        super.loadView()
        
        navigationTitle(self, "askTitle".localized)
//        sc = SWSegmentedControl(items: ["Q&A", "contact".localized, "reply".localized])
        
        backBtn.image = UIImage(named:"backBtn")?.withRenderingMode(.alwaysOriginal)
        
        let controller = WKUserContentController()
        controller.add(self, name: "startAnswerActivity")
        controller.add(self, name: "imageUpload")
        
        let configuration = WKWebViewConfiguration()
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
            "form.action = '\(domain+url)';" +
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
        refreshControl.addTarget(self, action: #selector(refreshWebView(_:)), for: .valueChanged)
        wkWebView.scrollView.addSubview(refreshControl)
    }
    
    func refreshWebView(_ sender: UIRefreshControl) {
        wkWebView.reload()
        sender.endRefreshing()
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "startAnswerActivity" {
            let scriptMessage = message.body as! String
            print("scriptMessage: \(scriptMessage)")

            segmentedControl(sc, canSelectItemAtIndex: 2)
            sc.setSelectedSegmentIndex(2, animated: true)

        }
        if message.name == "imageUpload" {
            let message = message.body as! String
            
            if message == "open" {
                let alert = UIAlertController(title: "changeProfilImg".localized, message: nil, preferredStyle: .actionSheet)
                
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
        pickerController.maxSelectableCount = 8
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
    
    func segmentedControl(_ control: SWSegmentedControl, canSelectItemAtIndex index: Int) -> Bool {
        if index == 0 {
            //Q&A
            print("Q&A")
            settingWebView(url: QandAURL)
            
        } else if index == 1 {
            //1:1 문의
            print("1:1 문의")
            settingWebView(url: contactURL)
            
        } else if index == 2{
            //1:1 답변
            print("1:1 답변")
            settingWebView(url: answerURL)
            
        }
        return true
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
    
    @IBAction func DoneBtn(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "questionAlert")
        self.dismiss(animated: true, completion: nil)
        
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
                    print("result : \(result)")
                    print("response : \(response)")
                    
                    if let img = response.result.value as? [String : Any] {
                        
                        print("new_image : \(img["new_image"])")
                        
                        if let we = img["new_image"] as? [Any] {
                            print((we.first as! [String : String])["src"]!)
                            self.imgUrl = (we.first as! [String: String])["src"]!
                        }
                        
                    }
                    print("imgUrl : \(self.imgUrl)")
                    self.wkWebView.evaluateJavaScript("iosimg('\(self.imgUrl)')", completionHandler: nil)
                    
                }
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
            }
        }
    }
}
