//
//  LanguageController.swift
//  AllMarket
//
//  Created by 김민주 on 2017. 9. 25..
//  Copyright © 2017년 MinJu. All rights reserved.
//

import UIKit
import Alamofire

class LanguageController: UIViewController {

    @IBOutlet weak var amLogo: UIImageView!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var koreanView: UIView!
    @IBOutlet weak var englishView: UIView!
    @IBOutlet weak var vietnameseView: UIView!
    
    let myData = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.init(hex: "051c30")
        
        let mainWidth = self.view.frame.width
        let mainHeight = self.view.frame.height

        let mainWidthCenter = mainWidth / 2
        
        amLogo.frame = CGRect(x: 0, y: 0, width: 190, height: 126)
        amLogo.center.x = mainWidthCenter
        amLogo.frame.origin.y = mainHeight - 570

        lineView.frame = CGRect(x: 0, y: 0, width: mainWidth - (44.5 * 2), height: 1)
        lineView.center.x = mainWidthCenter
        lineView.frame.origin.y = mainHeight - 381

        koreanView.center.x = mainWidthCenter
        koreanView.frame.origin.y = mainHeight - 298

        englishView.center.x = mainWidthCenter
        englishView.frame.origin.y = mainHeight - 209

        vietnameseView.center.x = mainWidthCenter
        vietnameseView.frame.origin.y = mainHeight - 119
    }
    
    @IBAction func Korean(_ sender: UIButton) {
        myData.set("한국어", forKey: "selectLanguage")
        myData.set("korea", forKey: "selectLanguageEng")
        
        let selectLanguageEng = myData.object(forKey: "selectLanguageEng") as! String
        
        if L102Language.currentAppleLanguage() == "ko" {
            L102Language.setAppleLAnguageTo(lang: "ko")
        } else {
            L102Language.setAppleLAnguageTo(lang: "ko")
        }
        
        self.requestLanguage(lang: selectLanguageEng)
        
    }
    
    @IBAction func English(_ sender: UIButton) {
        myData.set("English", forKey: "selectLanguage")
        myData.set("english", forKey: "selectLanguageEng")
        
        let selectLanguageEng = myData.object(forKey: "selectLanguageEng") as! String
        
        if L102Language.currentAppleLanguage() == "ko" {
            L102Language.setAppleLAnguageTo(lang: "en")
        } else {
            L102Language.setAppleLAnguageTo(lang: "en")
        }
        
        self.requestLanguage(lang: selectLanguageEng)
    }
    
    @IBAction func vitenam(_ sender: UIButton) {
        myData.set("tiếng việt", forKey: "selectLanguage")
        myData.set("vietnamese", forKey: "selectLanguageEng")
        
        let selectLanguageEng = myData.object(forKey: "selectLanguageEng") as! String
        
        if L102Language.currentAppleLanguage() == "ko" {
            L102Language.setAppleLAnguageTo(lang: "vi")
        } else {
            L102Language.setAppleLAnguageTo(lang: "vi")
        }
        
        self.requestLanguage(lang: selectLanguageEng)
    }
    
    func requestLanguage(lang: String) {
        var parameter = ["":""]
        if myData.object(forKey: "user_idx") == nil {
            parameter = ["lang":lang]
        } else {
            let user_idx = myData.object(forKey: "user_idx") as! String
            parameter = ["lang":lang,
                         "user_idx": user_idx]
        }
        print("[ English ] : \(lang)")
        
        Alamofire.request(domain + languageURL, method: .post, parameters: parameter, encoding: URLEncoding.default, headers: nil).response(completionHandler: { (response) in
            print("response : \(response)")
            //            self.parseLanguage(JSONData: response.data!)
            if (self.myData.object(forKey: "email") != nil) && (self.myData.object(forKey: "pass") != nil) {
                changeView(target: self, identifier: "Home")
            } else {
                changeView(target: self, identifier: "LoginView")
            }
        })
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
