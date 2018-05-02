//
//  ChangePhoneNumController.swift
//  AllMarket
//
//  Created by 김민주 on 2017. 8. 28..
//  Copyright © 2017년 MinJu. All rights reserved.
//

import UIKit
import Alamofire

class ChangePhoneNumController: UIViewController {
    
    var tel = ""
    
    let scrollView: UIScrollView = UIScrollView()

    @IBOutlet weak var backBtn: UIBarButtonItem!
    @IBOutlet weak var phoneNumTextField: UITextField!
    @IBOutlet weak var completionBtn: UIButton!
    
    @IBOutlet weak var guideViewY: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if L102Language.currentAppleLanguage() == "ko" {
            navigationTitle(self, "전화번호 변경")
        } else if L102Language.currentAppleLanguage() == "en" {
            navigationTitle(self, "Change phone number")
        } else if L102Language.currentAppleLanguage() == "vi" {
            navigationTitle(self, "Thay đổi số điện thoại")
        }
        
        navigationTitle(self, "changeTelTitle".localized)
        
        guideViewY.constant = (self.view.frame.height - 110) / 2
        
        backBtn.image = UIImage(named:"backBtn")?.withRenderingMode(.alwaysOriginal)
        completionBtn.backgroundColor = UIColor.init(hex: "051c30")
        
        self.view.addSubview(scrollView)
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 1 {
            moveTextField(textField, moveDistance: -100, up: true)
            
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 1 {
            moveTextField(textField, moveDistance: -100, up: false)
            
        }
    }
    
    func moveTextField(_ textField: UITextField, moveDistance: Int, up: Bool) {
        let moveDuration = 0.3
        let movement = CGFloat(up ? moveDistance : -moveDistance)
        
        UIView.beginAnimations("animatedTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }

    @IBAction func telCheckBtn(_ sender: UIButton) {
        
        if phoneNumTextField.text == "" {
            basicAlert(target: self, title: nil, message: "phoneNumOK".localized)
            
        }else{
            tel = phoneNumTextField.text!
            
            guard isValidPhoneNum(str: tel) else {
                basicAlert(target: self, title: nil, message: "notPhoneNum".localized)
                
                return
            }
            let parameter = ["tel":tel]
            
            Alamofire.request(domain + telCheckURL, method: .post, parameters: parameter, encoding: URLEncoding.default, headers: nil).response(completionHandler: { (response) in
                self.parseTelCheck(JSONData: response.data!)
            })
            
        }
        
    }
    
    func parseTelCheck(JSONData: Data) {
        do {
            let readableJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! [String:AnyObject]
            print("JSON : \(readableJSON)")
            
            let telCheckState = readableJSON["result"] as! String
            print("@@@@ telCheckState : \(telCheckState) @@@@")
            
            if telCheckState == "false" {
                basicAlert(target: self, title: nil, message: "phoneNumOK".localized)
                
            } else {
                phoneNumTextField.text = ""
                
                basicAlert(target: self, title: nil, message: "overlapPhoneNum".localized)
            }
            
        }catch{
            print("[ Fail ]")
            print("parse nickname dup check error : \(error)")
        }
    }
    
    @IBAction func ChangeTel(_ sender: UIButton) {
        
        let user_idx = UserDefaults.standard.string(forKey: "user_idx") as! String
        let parameter = ["phone":tel,
                         "user_idx":user_idx]
        print("parameter : \(parameter)")
        
        Alamofire.request(domain + newPhoneURL, method: .post, parameters: parameter, encoding: URLEncoding.default, headers: nil)
        if phoneNumTextField.text == "" {
            basicAlert(target: self, title: nil, message: "inputPhoneNum".localized)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    @IBAction func DoneBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
