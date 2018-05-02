//
//  NewPasswordController.swift
//  AllMarket
//
//  Created by MAC on 2017. 9. 6..
//  Copyright © 2017년 MinJu. All rights reserved.
//

import UIKit
import Alamofire

class NewPasswordController: UIViewController {
    
    var password = ""
    
    @IBOutlet weak var backBtn: UIBarButtonItem!
    @IBOutlet weak var tfExistingPW: UITextField!   //기존 비밀번호
    @IBOutlet weak var tfNewPW: UITextField!        //새 비밀번호
    @IBOutlet weak var tfConfirmPW: UITextField!    //새 비밀번호 확인
    @IBOutlet weak var completionBtn: UIButton!
    
    @IBOutlet weak var guideViewY: NSLayoutConstraint!
    
    let myData = UserDefaults.standard
    
    var message = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if L102Language.currentAppleLanguage() == "ko" {
//            navigationTitle(self, "새 비밀번호 설정")
//        } else if L102Language.currentAppleLanguage() == "en" {
//            navigationTitle(self, "Set a new password")
//        } else if L102Language.currentAppleLanguage() == "vi" {
//            navigationTitle(self, "Đặt mật khẩu mới")
//        }
        
        navigationTitle(self, "newPWTitle".localized)
        
        guideViewY.constant = (self.view.frame.height - 110) / 2
        
        tfExistingPW.isSecureTextEntry = true
        tfNewPW.isSecureTextEntry = true
        tfConfirmPW.isSecureTextEntry = true
        
        backBtn.image = UIImage(named:"backBtn")?.withRenderingMode(.alwaysOriginal)
        completionBtn.backgroundColor = UIColor.init(hex: "051c30")
    }
    
    @IBAction func ChangePW(_ sender: UIButton) {
        //현재 비밀번호
        let existingPW = myData.string(forKey: "existing_pw")!
        
        if existingPW != tfExistingPW.text! {
            
            if L102Language.currentAppleLanguage() == "ko" {
                message = "현재 비밀번호를 다시 입력해주십시오."
            } else if L102Language.currentAppleLanguage() == "en" {
                message = "Please re-enter the current password."
            } else if L102Language.currentAppleLanguage() == "vi" {
                message = "Hãy nhập mật khẩu hiện tại."
            }
            
            basicAlert(target: self, title: nil, message: message)
        } else {
            
            if tfNewPW.text! == existingPW {
                if L102Language.currentAppleLanguage() == "ko" {
                    message = "현재 비밀번호와 같습니다. 다르게 설정해주십시오."
                } else if L102Language.currentAppleLanguage() == "en" {
                    message = "Same as the current password. Set it differently."
                } else if L102Language.currentAppleLanguage() == "vi" {
                    message = "HĐây là ám hiệu và mật khẩu. Tôi sẽ thiết lập khác."
                }
                
                basicAlert(target: self, title: nil, message: message)
                
            } else {
            
                if (tfNewPW.text!.characters.count < 5) && (tfConfirmPW.text!.characters.count < 5) {
                    
                    basicAlert(target: self, title: nil, message: "pwMinimum".localized)
                    
                } else {
                    
                    comparePassword(target: self, passStr1: tfNewPW.text!, passStr2: tfConfirmPW.text!)
                    
                    password = tfNewPW.text!
                    
                    let user_idx = myData.string(forKey: "user_idx") as! String
                    let parameter = ["newpw":password,
                                     "user_idx":user_idx]
                    myData.set(password, forKey: "newpw")
                    print("@@@@@ \(parameter) @@@@@")
                    
                    Alamofire.request(domain + newPassWordURL,
                                      method: .post,
                                      parameters: parameter,
                                      encoding: URLEncoding.default,
                                      headers: nil).response(completionHandler: {
                                        (response) in
                                        self.parseNewPassword(JSONData: response.data!)
                                      })
//                    self.dismiss(animated: true, completion: nil)
                    self.navigationController?.popViewController(animated: true)
                    
                }
            }
            
        }
 
    }
    
    func parseNewPassword(JSONData: Data){
        do{
            let readableJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! [String : AnyObject]
            print("JSON : \(readableJSON)")
            
            let newpw = readableJSON["result"] as? String
            
            if newpw == "true"{
            
                basicAlert(target: self, title: nil, message: "비밀번호 변경이 완료됐습니다.")
                print("#### 비밀번호 변경 성공 ####")
            } else {
                print("#### 비밀번호 변경 실패 ####")
            }
            
            
        }catch{
            print("[ Fail ]")
            basicAlert(target: self, title: "비밀번호 변경 오류", message: "다시 시도해주세요.")
            print(" NewPassword error : \(error)")
            
        }
    }
    
    @IBAction func DoneBtn(_ sender: UIBarButtonItem) {
        
//        self.presentingViewController?.dismiss(animated: true)
        self.navigationController?.popViewController(animated: true)
    }
    
}
