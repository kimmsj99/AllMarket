//
//  FBJoinController.swift
//  AllMarket
//
//  Created by 김민주 on 2017. 10. 27..
//  Copyright © 2017년 MinJu. All rights reserved.
//

import UIKit
import Alamofire

class FBJoinController: UIViewController, UITextFieldDelegate {
    
    let myData = UserDefaults.standard
    let language = UserDefaults.standard.object(forKey: "selectLanguageEng") as! String
    
    var nickName = ""
    var tel = ""

    @IBOutlet weak var nickNameTF: UITextField!
    @IBOutlet weak var telTF: UITextField!
    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var completionBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        completionBtn.backgroundColor = UIColor.init(hex: "051c30")
        
        var tmpView = UIView()
        
        if UIScreen.main.nativeBounds.height == 2436 {
            tmpView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 44.0 ))
            tmpView.backgroundColor = UIColor.init(hex: "051c30")
            self.view.addSubview(tmpView)
        } else {
            tmpView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 20.0 ))
            tmpView.backgroundColor = UIColor.init(hex: "051c30")
            self.view.addSubview( tmpView )
            
        }
        
        backBtn.addTarget(self, action: #selector(DoneBtn(_:)), for: .touchUpInside)
        
        self.setNeedsStatusBarAppearanceUpdate()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // LoginViewController에서만 네비게이션바 안 보이게
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 다른 뷰에선 네비게이션바 보이게
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentCharacterCount = textField.text?.utf8.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        
        let newLength = currentCharacterCount + string.characters.count - range.length
        return newLength <= 10
    }
    
    @IBAction func nickNameCheckBtn(_ sender: UIButton) {
        if nickNameTF.text == "" {
            basicAlert(target: self, title: nil, message: "inputNickname".localized)
            
        } else {
            nickName = nickNameTF.text!
            
            let parameter = ["nickname":nickName]
            //            print(parameter)
            
            Alamofire.request(domain + nicknameCheckURL, method: .post, parameters: parameter, encoding: URLEncoding.default, headers: nil).response(completionHandler: { (response) in
                self.parseNicknameCheck(JSONData: response.data!)
            })
        }
    }
    
    @IBAction func telCheckBtn(_ sender: UIButton) {
        if telTF.text == "" {
            basicAlert(target: self, title: nil, message: "inputPhoneNum".localized)
            
        }else{
            tel = telTF.text!
            
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
    
    func parseNicknameCheck(JSONData: Data) {
        do {
            let readableJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! [String:AnyObject]
            print("JSON : \(readableJSON)")
            
            let nicknameCheckState = readableJSON["result"] as! String
            
            //false가 나와야 중복이 아님 / true가 나올 시 중복
            if nicknameCheckState == "false" {
                
                basicAlert(target: self, title: nil, message: "nickOK".localized)
                
            } else {
                nickNameTF.text = ""
                
                basicAlert(target: self, title: nil, message: "overlapNick".localized)
            }
            
        }catch{
            print("[ Fail ]")
            basicAlert(target: self, title: "닉네임 중복확인 오류", message: "다시 시도해주세요.")
            print("parse nickname dup check error : \(error)")
        }
    }
    
    func parseTelCheck(JSONData: Data) {
        do {
            let readableJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! [String:AnyObject]
            print("JSON : \(readableJSON)")
            
            let telCheckState = readableJSON["result"] as! String
            
            if telCheckState == "false" {
                
                basicAlert(target: self, title: nil, message: "phoneNumOK".localized)
                
            } else {
                telTF.text = ""
                
                basicAlert(target: self, title: nil, message: "overlapPhoneNum".localized)
            }
            
        }catch{
            print("[ Fail ]")
            basicAlert(target: self, title: "전화번호 중복확인 오류", message: "다시 시도해주세요.")
            print("parse nickname dup check error : \(error)")
        }
    }
    
    @IBAction func FBJoinAction(_ sender: UIButton) {
        if nickName != nickNameTF.text! {
            
            basicAlert(target: self, title: nil, message: "checkNickname".localized)
            
        } else {
            
            if tel != telTF.text! {
                
                basicAlert(target: self, title: nil, message: "checkPhoneNum".localized)
                
            } else {
                
                let email = myData.object(forKey: "facebookEmail") as! String
                let password = "facebook@login"
                
                let parameter = ["email":email,
                                 "pw":password,
                                 "nickname":nickName,
                                 "tel":tel,
                                 "joinpath":"FACEBOOK"]
                
                Alamofire.request(domain + joinURL,
                                  method: .post,
                                  parameters: parameter,
                                  encoding: URLEncoding.default,
                                  headers: nil).response(completionHandler: {
                                    (response) in
                                    self.parseJoin(JSONData: response.data!)
                })
            }
        }
    }
    
    func parseJoin(JSONData: Data){
        do {
            let readableJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! [String:AnyObject]
            print("회원가입 JSON : \(readableJSON)")
            
            let joinState = readableJSON["result"] as! String
            
            if joinState == "true" {
                
                if myData.object(forKey: "token") != nil {
                
                    let token = myData.object(forKey: "token") as! String
                    
                    let email = myData.object(forKey: "facebookEmail") as! String
                    let pass = "facebook@login"
                    let parameter = ["email":email,
                                 "pw":pass,
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
                
//                basicAlert(target: self, title: nil, message: "회원가입이 완료되었습니다.")
                
            } else {
                
                basicAlert(target: self, title: nil, message: "joinFail".localized)
            }
            
        } catch {
            print("[ Fail ]")
            basicAlert(target: self, title: "회원가입 오류", message: "다시 시도해주세요.")
            print("fbjoin error : \(error)")
        }
        
    }
    
    func parseLogin(JSONData: Data) {
        do{
            let readableJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! [String:AnyObject]
            print("로그인 JSON : \(readableJSON)")
            
            let loginState = readableJSON["result"] as! String
            
            if loginState == "true" {
                //로그인 성공
                
                let email = myData.object(forKey: "facebookEmail") as! String
                let pass = "facebook@login"
                myData.set(email, forKey: "email")
                myData.set(pass, forKey: "pass")
                myData.set(readableJSON["user_idx"], forKey: "user_idx")
                myData.set(readableJSON["menu"], forKey: "menu")
                myData.set(readableJSON["warning"], forKey: "blackMem")
                print("@@@@ \(myData.object(forKey: "user_idx")!) @@@@")
                print("@@@@ \(myData.object(forKey: "menu")!) @@@@")
                
                print("@@@@ Login Success @@@@")
                
                self.dismiss(animated: true, completion: nil)
                
            }else{
                //로그인 실패
                basicAlert(target: self, title: "loginFail".localized, message: "again".localized)
            }
            
        }catch{
            print(" error \(error)")
            basicAlert(target: self, title: "파싱 실패", message: "다시 시도해주세요")
        }
    }
    
    func DoneBtn(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}
