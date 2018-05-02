//
//  AmTouController.swift
//  AllMarket
//
//  Created by 김민주 on 2017. 9. 25..
//  Copyright © 2017년 MinJu. All rights reserved.
//

import UIKit
import Alamofire
import SWSegmentedControl

class AmTouController: UIViewController, SWSegmentedControlDelegate {

    @IBOutlet weak var backBtn: UIBarButtonItem!
    @IBOutlet weak var textView: UITextView!
    
    let language = UserDefaults.standard.object(forKey: "selectLanguageEng") as! String
    
    var sc = SWSegmentedControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.scrollsToTop = true
        textView.isEditable = false
        
        backBtn.image = UIImage(named:"backBtn")?.withRenderingMode(.alwaysOriginal)
        
//        if L102Language.currentAppleLanguage() == "ko" {
//
//            navigationTitle(self, "약관 전문보기")
//            sc = SWSegmentedControl(items: ["이용약관", "개인정보 취급방침"])
//
//        } else if L102Language.currentAppleLanguage() == "en" {
//
//            navigationTitle(self, "See full terms and conditions")
//            sc = SWSegmentedControl(items: ["Terms of Use", "Privacy Statement"])
//
//        } else if L102Language.currentAppleLanguage() == "vi" {
//
//            navigationTitle(self, "Xem các điều khoản và điều kiện đầy đủ")
//            sc = SWSegmentedControl(items: ["Điều khoản sử dụng", "Cam kết bảo mật"])
//
//        }
        
        navigationTitle(self, "conditionsTitle".localized)
        sc = SWSegmentedControl(items: ["touTitle".localized, "privateTitle".localized])
        
        self.parseTou(url: amTosURL)
        
        let width = self.view.frame.size.width
        
        sc.frame = CGRect(x: 0, y: 0, width: width, height: 35)
        segmentedColor(sc)
        sc.delegate = self
        self.view.addSubview(sc)
    }
    
    func segmentedControl(_ control: SWSegmentedControl, canSelectItemAtIndex index: Int) -> Bool {
        if index == 0 {
            //이용약관
            print("이용약관")
            
            parseTou(url: amTosURL)
            
        } else if index == 1 {
            //개인정보
            print("개인정보취급방침")
            
            parseTou(url: amPinfoURL)
        }
        return true
    }
    
    func parseTou(url: String){

        let url = domain + url + "/\(language)"

        let categoryURL: URL! = URL(string: url)

        let data = try! Data(contentsOf: categoryURL)

//        let log = NSString(data: data, encoding: String.Encoding.utf8.rawValue) ?? ""
//        NSLog("API Result=\(log)")

        do{
            let readableJSON = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! NSDictionary
            print("JSON : \(readableJSON)")

            textView.text = readableJSON[language] as! String

        }catch{
            print(" error \(error)")
            basicAlert(target: self, title: "파싱 실패", message: "다시 시도해주세요")
        }


    }
    
    @IBAction func DoneBtn(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
//        self.dismiss(animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
