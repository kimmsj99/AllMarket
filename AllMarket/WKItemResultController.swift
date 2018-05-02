//
//  WKItemController.swift
//  AllMarket
//
//  Created by 김민주 on 2017. 9. 26..
//  Copyright © 2017년 MinJu. All rights reserved.
//

import UIKit
import WebKit
import Alamofire
import BTNavigationDropdownMenu
import TZSegmentedControl

class WKItemResultController: UIViewController, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {
    
    @IBOutlet weak var guideView: UIView!
    @IBOutlet weak var backBtn: UIBarButtonItem!
    @IBOutlet weak var searchBtn: UIBarButtonItem!
    @IBOutlet weak var optionBtn: UIBarButtonItem!
    
    let myData : UserDefaults = UserDefaults.standard
    
    var wkWebView = WKWebView()
    var refresher: UIRefreshControl!
    var searchController: UISearchController!
    var activityIndicator = UIActivityIndicatorView()
    
    var search : (() -> ())?
    
    var menuView: BTNavigationDropdownMenu!
    var titleCont: TZSegmentedControl!
    var middleArr = [String]()  //중분류 메뉴
    var smallArr = [String]()   //소분류 메뉴
    var middleIdxArr = [String]()
    var smallIdxArr = [String]()
    
    var Bidx = ""
    var Midx = ""
    var Sidx = ""
    
    let user_idx = UserDefaults.standard.object(forKey: "user_idx") as! String
    let language = UserDefaults.standard.object(forKey: "selectLanguageEng") as! String
    
    let queue = DispatchQueue(label: "com.cnoon.response-queue", qos: .utility, attributes: [.concurrent])
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.middleArr.removeAll()
        self.smallArr.removeAll()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.middleArr.removeAll()
        self.smallArr.removeAll()
        self.settingWebView()
        self.addRefreshControl()
    }
    
    override func viewDidLoad() {
        
        self.middleArr.removeAll()
        self.smallArr.removeAll()
        
        self.settingWebView()
        self.addRefreshControl()
        self.naviMenu()
        self.scrollMenu()
        
    }
    
    override func loadView() {
        super.loadView()
        
        backBtn.image = UIImage(named:"backBtn")?.withRenderingMode(.alwaysOriginal)
        searchBtn.image = UIImage(named:"searchBtn")?.withRenderingMode(.alwaysOriginal)
        optionBtn.image = UIImage(named:"optionBtn")?.withRenderingMode(.alwaysOriginal)
        
        let controller = WKUserContentController()
        controller.add(self, name: "startProductActivity")
        controller.add(self, name: "setMenu")
        
        let configuration = WKWebViewConfiguration()
        configuration.processPool = session.processPool
        configuration.userContentController = controller
        
        wkWebView = WKWebView(frame: self.guideView.frame, configuration: configuration)
        
        wkWebView.autoresizingMask = [.flexibleWidth, .flexibleHeight ]
        wkWebView.scrollView.isScrollEnabled = true
        wkWebView.scrollView.bounces = true
        wkWebView.uiDelegate = self
        wkWebView.navigationDelegate = self
        
        self.guideView.addSubview(wkWebView)
        
    }
    
    func naviMenu(){
        
        if myData.object(forKey: "keyword") == nil {
            
            var naviTitle = ""
            if myData.object(forKey: "BTitle") as? String == "0" {
                if myData.object(forKey: "bestLink") as! String == "1"{
                    naviTitle = "sell".localized
                } else {
                    naviTitle = "buy".localized
                }
                
            } else {
                if myData.object(forKey: "MTitle") == nil {
                    naviTitle = myData.string(forKey: "BTitle")!
                } else {
                    naviTitle = myData.string(forKey: "MTitle")!
                }
            }
            
            parseMCategory { [weak self] in
                
                print(self?.middleArr)
                
                if (self?.middleArr)! == [] {
                    self?.middleArr = ["sell".localized, "buy".localized]
                    self?.middleIdxArr = ["1", "2"]
                }
                
                let items = self?.middleArr
                self?.navigationController?.navigationBar.isTranslucent = false
                self?.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
                
                if (self?.middleArr)?.count == 2 {
                    if self?.myData.object(forKey: "bestLink") as! String == "1"{
                        self?.menuView = BTNavigationDropdownMenu(title: (self?.middleArr[0])!, items: items!)
                    } else {
                        self?.menuView = BTNavigationDropdownMenu(title: (self?.middleArr[1])!, items: items!)
                    }
                } else {
                    self?.menuView = BTNavigationDropdownMenu(title: naviTitle, items: items!)
                }
                
                let arrowImg = UIImage(named: "downArrowImg")
                
                self?.menuView.arrowImage = arrowImg
                self?.menuView.checkMarkImage = nil
                self?.menuView.cellHeight = 45
                self?.menuView.navigationBarTitleFont = UIFont.systemFont(ofSize: 17)
                self?.menuView.cellBackgroundColor = self?.navigationController?.navigationBar.barTintColor
                self?.menuView.shouldKeepSelectedCellColor = true
                self?.menuView.cellSelectionColor = self?.navigationController?.navigationBar.barTintColor
                self?.menuView.selectedCellTextLabelColor = UIColor.init(hex: "FCFCFC")
                self?.menuView.cellTextLabelColor = UIColor.init(hex: "FCFCFC")
                self?.menuView.cellTextLabelFont = UIFont.systemFont(ofSize: 13)
                self?.menuView.cellTextLabelAlignment = .center // .Center // .Right // .Left
                self?.menuView.arrowPadding = 10
                self?.menuView.animationDuration = 0.5
                self?.menuView.maskBackgroundColor = UIColor.black
                self?.menuView.maskBackgroundOpacity = 0.3
                self?.menuView.cellSeparatorColor = self?.navigationController?.navigationBar.barTintColor
                self?.menuView.didSelectItemAtIndexHandler = {(indexPath: Int) -> Void in
//                    print("Did select item at index: \(self?.middleIdxArr[indexPath])")
                    
                    if self?.myData.object(forKey: "Midx") == nil {
                        
                        self?.myData.set(self?.middleIdxArr[indexPath], forKey: "bestLink")
                        
                    } else {
                        
                        if self?.myData.object(forKey: "Sidx") == nil {
                            
                            self?.myData.set(self?.middleIdxArr[indexPath], forKey: "Bidx")
                            
                        } else {
                            
                            self?.myData.set(self?.middleIdxArr[indexPath], forKey: "Midx")
                        }
                    }
                    
                    navigationTitle(self!, items![indexPath])
                    self?.scrollMenu()
                    self?.settingWebView()
                    
                }
                
                self?.navigationItem.titleView = self?.menuView
            }
        }
    }
    
    func scrollMenu(){
        
        parseSCategory { [weak self] in
        
            let menu = self?.smallArr
            print("소분류: \(menu)")

            self?.titleCont = TZSegmentedControl(sectionTitles: menu!)

            self?.titleCont.frame = CGRect(x: 0, y: 0, width: (self?.view.frame.width)!, height: 35)
            self?.titleCont.indicatorWidthPercent = 0.8
            let whitishColor = UIColor(white: 0.75, alpha: 0.2)
            self?.titleCont.backgroundColor = UIColor.white
            self?.titleCont.borderType = .none
            self?.titleCont.borderWidth = 0.5
            self?.titleCont.borderColor = whitishColor
            self?.titleCont.segmentWidthStyle = .dynamic
            self?.titleCont.verticalDividerEnabled = false
            self?.titleCont.verticalDividerWidth = 0.5
            self?.titleCont.verticalDividerColor = whitishColor
            self?.titleCont.selectionStyle = .fullWidth
            self?.titleCont.selectionIndicatorLocation = .down
            self?.titleCont.selectionIndicatorColor = UIColor.init(hex: "051c30")
            self?.titleCont.selectionIndicatorHeight = 2.0
            self?.titleCont.edgeInset = UIEdgeInsets(top: 0, left: 15.5, bottom: 0, right: 15.5)
            self?.titleCont.selectedTitleTextAttributes = [NSForegroundColorAttributeName:UIColor.init(hex: "353535")]
            self?.titleCont.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.init(hex: "a7a7a7"),
                                             NSFontAttributeName: UIFont.systemFont(ofSize: 13)]
            self?.titleCont.indexChangeBlock = { (index) in
                print("Segmented \(self?.smallIdxArr[index]) is visible now")
                
                if self?.myData.object(forKey: "Midx") == nil {
                    self?.myData.set(self?.smallIdxArr[index], forKey: "Bidx")
                    
                } else {
                    
                    if self?.myData.object(forKey: "Sidx") == nil {
                        self?.myData.set(self?.smallIdxArr[index], forKey: "Midx")
                        
                    } else {
                        self?.myData.set(self?.smallIdxArr[index], forKey: "Sidx")
                        
                    }
                }
                self?.settingWebView()
                
            }
            self?.view.addSubview((self?.titleCont)!)
            
        }
    }
    
    func settingWebView() {
        
        var url: String
        
//        var searchRes = myData.object(forKey: "searchRes") as! String
//        var filterRes = myData.object(forKey: "filterRes") as! String
        
        var searchRes: String
        var filterRes: String
        
        if myData.object(forKey: "searchRes") != nil && myData.object(forKey: "filterRes") != nil {
            searchRes = myData.object(forKey: "searchRes") as! String
            filterRes = myData.object(forKey: "filterRes") as! String
            
        } else {
            searchRes = "null"
            filterRes = "null"
        }
        
        if myData.object(forKey: "bestLink") != nil {
            let bestLink = myData.object(forKey: "bestLink") as! String
            
            if myData.object(forKey: "Bidx") == nil {
                
                url = domain + itemResultURL + "/\(bestLink)/\(searchRes)/\(filterRes)"
                
            } else {
                if myData.object(forKey: "Midx") == nil {
                    Bidx = myData.object(forKey: "Bidx") as! String
                    
                    let category = "\(bestLink),\(Bidx)"
                    myData.set(category, forKey: "Category")
                    
                    url = domain + itemResultURL + "/\(bestLink),\(Bidx)/\(searchRes)/\(filterRes)"
                    
                } else {
                    Bidx = myData.object(forKey: "Bidx") as! String
                    Midx = myData.object(forKey: "Midx") as! String
                    
                    if myData.object(forKey: "Sidx") == nil {
                        
                        let category = "\(bestLink),\(Bidx),\(Midx)"
                        myData.set(category, forKey: "Category")
                        
                        url = domain + itemResultURL + "/\(bestLink),\(Bidx),\(Midx)/\(searchRes)/\(filterRes)"
                        
                    } else {
                        Sidx = myData.object(forKey: "Sidx") as! String
                        
                        let category = "\(bestLink),\(Bidx),\(Midx),\(Sidx)"
                        myData.set(category, forKey: "Category")
                        
                        url = domain + itemResultURL + "/\(bestLink),\(Bidx),\(Midx),\(Sidx)/\(searchRes)/\(filterRes)"
                        
                    }
                }
            }
            
            let javascriptPOSTRedirect = "" +
                "var form = document.createElement('form');" +
                "form.method = 'POST';" +
                "" +
                "form.action = '\(url)';" +
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
            print(javascriptPOSTRedirect)
            
            wkWebView.evaluateJavaScript(javascriptPOSTRedirect, completionHandler: nil)
            
        }
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
            
            print("message : \(message)")
            
            UserDefaults.standard.set(url, forKey: "ItemInfoURL")
            UserDefaults.standard.set(idx, forKey: "ItemInfoIdx")
            
            let ItemInfo = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ItemInfo") as!  WKItemInfoController
            self.navigationController?.pushViewController(ItemInfo, animated: true)
            
//            changeView(target: self, identifier: "ItemInfo")
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
    
    @IBAction func searchAction(_ sender: UIBarButtonItem) {
        
        dismiss(animated: false) {
            self.search?()
        }
        
    }
    
    @IBAction func GoFiltering(_ sender: UIBarButtonItem) {
        let Filtering = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Filtering") as! WKFilteringController
        self.navigationController?.pushViewController(Filtering, animated: true)
    }
    
    @IBAction func DoneBtn(_ sender: UIBarButtonItem) {
        if myData.object(forKey: "bestLink") as? String != myData.object(forKey: "bestLinkChange") as? String {
            let bestLink = myData.object(forKey: "bestLinkChange") as! String
            myData.set(bestLink, forKey: "bestLink")
        }
        myData.removeObject(forKey: "Sidx")
        self.menuView.hide()
        self.dismiss(animated: true, completion: nil)
    }
    
}
