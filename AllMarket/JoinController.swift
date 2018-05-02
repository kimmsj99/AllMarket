//
//  JoinViewController.swift
//  AllMarket
//
//  Created by MAC on 2017. 8. 9..
//  Copyright © 2017년 MinJu. All rights reserved.
//

import UIKit
import Alamofire

//회원가입 페이지
class JoinController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate {
    
    var email = ""
    var password = ""
    var certificationNum = ""    //인증번호 랜덤
    var nickName = ""
    var tel = ""
    
    var emailCheck = false
    var certifiNumCheck = false
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var topInterval: NSLayoutConstraint!
    @IBOutlet weak var bottomInterval: NSLayoutConstraint!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var emailTextField: UITextField!         //이메일 입력란
    @IBOutlet weak var certifiNumTextField: UITextField!    //인증번호 입력란
    @IBOutlet weak var pwTextField: UITextField!            //비밀번호 입력란
    @IBOutlet weak var pwConfirmTextField: UITextField!     //비밀번호 확인 입력란
    @IBOutlet weak var nickNameTextField: UITextField!      //닉네임 입력란
    @IBOutlet weak var telTextField: UITextField!           //휴대폰 번호 입력란
    
    @IBOutlet weak var emailBtn: UIButton!          //이메일 체크 버튼
    @IBOutlet weak var certifiNumBtn: UIButton!     //인증번호 체크 버튼
    
    @IBOutlet weak var completionBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        completionBtn.backgroundColor = UIColor.init(hex: "051c30")

        //비밀번호 안 보이게 만들기
        pwTextField.isSecureTextEntry = true
        pwConfirmTextField.isSecureTextEntry = true
        
        pwConfirmTextField.delegate = self
        nickNameTextField.delegate = self
        telTextField.delegate = self
        scrollView.delegate = self
        
        addToolBar(target: self.view, textField: emailTextField)
        addToolBar(target: self.view, textField: certifiNumTextField)
        addToolBar(target: self.view, textField: pwTextField)
        addToolBar(target: self.view, textField: pwConfirmTextField)
        addToolBar(target: self.view, textField: nickNameTextField)
        addToolBar(target: self.view, textField: telTextField)
        
        password = pwTextField.text!
        
        var tmpView = UIView()
        
        if phoneHeight == iphoneX {
            tmpView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 44.0 ))
            tmpView.backgroundColor = UIColor.init(hex: "051c30")
            self.view.addSubview(tmpView)
        } else {
            tmpView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 20.0 ))
            tmpView.backgroundColor = UIColor.init(hex: "051c30")
            self.view.addSubview( tmpView )
            
        }
        
        if phoneHeight > iphone8 {
//            let half = containerView.frame.height / 2
            
            let centerY = (self.view.frame.height - (titleLabel.frame.maxY + completionBtn.frame.height)) / 2
            
            topInterval.constant = centerY - calculateHeightConstant(self, 24.5)
            bottomInterval.constant = centerY + calculateHeightConstant(self, 24.5)
            
        }
        
        print(topInterval.constant)
        print(bottomInterval.constant)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(noti:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(noti:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        scrollView.contentSize = contentView.frame.size

        self.setNeedsStatusBarAppearanceUpdate()
        
    }
    
    func keyboardWillShow(noti: Notification) {
        
        var userInfo = noti.userInfo
        let keyboardSize: CGSize = ((userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size)!
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height + 44, right: 0)
        
        scrollView.contentInset = contentInsets;
        scrollView.scrollIndicatorInsets = contentInsets;
        
        var offset = scrollView.contentOffset
        offset.y = scrollView.contentSize.height + scrollView.contentInset.bottom - scrollView.bounds.size.height
        //        scrollView.setContentOffset(offset, animated: true)
        
    }
    
    func keyboardWillHide(noti: Notification) {
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == nickNameTextField.self {
            let currentCharacterCount = textField.text?.utf8.count ?? 0
            if (range.length + range.location > currentCharacterCount){
                return false
            }
            
            let newLength = currentCharacterCount + string.characters.count - range.length
            return newLength <= 10
        }
        
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func compareCertificationNum(str: String, certifiNum: String){
        
        guard str == certifiNum else {
            
            basicAlert(target: self, title: nil, message: "certalertFail".localized)
            
            return ;
        }
        basicAlert(target: self, title: nil, message: "certalertSuccess".localized)
        
        certifiNumTextField.isEnabled = false
        certifiNumBtn.isEnabled = false
        
    }
    
    //이메일확인 버튼
    @IBAction func emailBtn(_ sender: UIButton) {
        if emailTextField.text == "" {
            basicAlert(target: self, title: nil, message: "emailInput".localized)
            
        }else{
            email = emailTextField.text!
            
            guard isValidEmail(str: email) else {
                basicAlert(target: self, title: nil, message: "notEmail".localized)
                
                return
            }
            
            certificationNum = random(length: 6)
            print("인증번호 : \(certificationNum)")
            let parameter = ["email":email,
                             "pass":certificationNum]
            
            Alamofire.request(domain + certifiNumURL, method: .post, parameters: parameter, encoding: URLEncoding.default, headers: nil).response(completionHandler: { (response) in
                do {
                    let readableJSON = try JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) as! [String:AnyObject]
                    
                    if readableJSON["result"] as? String == "true" {
                        basicAlert(target: self, title: nil, message: "sentCertNum".localized)
                        self.emailTextField.isEnabled = false
                        
                    } else {
                        basicAlert(target: self, title: nil, message: "overlapEmail".localized)
                        self.emailTextField.text = ""
                    }
                } catch {
                    basicAlert(target: self, title: nil, message: "파싱 실패")
                }
            })
            
            
            
        }

    }
    
    //인증번호 확인 버튼
    @IBAction func certifiNumCheck(_ sender: UIButton) {
        
        if certifiNumTextField.text == "" {
            basicAlert(target: self, title: nil, message: "inputCert".localized)
            
        } else {
            let certifiNumStr = certifiNumTextField.text!   //내가 입력한 값
            let certifiNum = certificationNum              //인증번호
            
            print("[ textField ] : \(certifiNumStr) #### [ CertifiNum ] : \(certifiNum)")
            compareCertificationNum(str: certifiNumStr, certifiNum: certifiNum)
        }
    }
    
    //닉네임 중복확인 버튼
    @IBAction func nickNameCheck(_ sender: UIButton) {
        
        if nickNameTextField.text == "" {
            basicAlert(target: self, title: nil, message: "inputNickname".localized)
            
        } else {
            nickName = nickNameTextField.text!
            
            let parameter = ["nickname":nickName]
//            print(parameter)
            
            Alamofire.request(domain + nicknameCheckURL, method: .post, parameters: parameter, encoding: URLEncoding.default, headers: nil).response(completionHandler: { (response) in
                self.parseNicknameCheck(JSONData: response.data!)
                print("@@@@ \(response.data!) @@@@")
            })
        }

    }
    
    //전화번호 중복확인 버튼
    @IBAction func telBtn(_ sender: UIButton) {
        
        if telTextField.text == "" {
            basicAlert(target: self, title: nil, message: "inputPhoneNum".localized)
            
        }else{
            tel = telTextField.text!
            
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
    
    func parseEmailSend(JSONData: Data){
        do {
            let readableJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! [String:AnyObject]
            print("JSON : \(readableJSON)")
            
            basicAlert(target: self, title: nil, message: "sentCertNum".localized)
            
        }catch{
            print("[ Fail ]")
            basicAlert(target: self, title: "인증번호 보내기 오류", message: "다시 시도해주세요.")
            print("parse nickname dup check error : \(error)")
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
                nickNameTextField.text = ""
                
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
                telTextField.text = ""
                
                basicAlert(target: self, title: nil, message: "overlapPhoneNum".localized)
            }
            
        }catch{
            print("[ Fail ]")
            basicAlert(target: self, title: "전화번호 중복확인 오류", message: "다시 시도해주세요.")
            print("parse nickname dup check error : \(error)")
        }
    }
    
    @IBAction func joinCompleteBtn(_ sender: UIButton) {
        
        password = pwTextField.text!
        
        if email != emailTextField.text!{
            
            basicAlert(target: self, title: nil, message: "checkEmail".localized)
            
        } else {
            if (password.characters.count < 5) && (pwConfirmTextField.text!.characters.count < 5) {
                
                basicAlert(target: self, title: nil, message: "pwMinimum".localized)
                
            } else {
                comparePassword(target: self, passStr1: password, passStr2: pwConfirmTextField.text!)
                
                if nickName != nickNameTextField.text! {
                    
                    basicAlert(target: self, title: nil, message: "checkNickname".localized)
                    
                } else {
                    
                    if tel != telTextField.text! {
                        
                        basicAlert(target: self, title: nil, message: "checkPhoneNum".localized)
                        
                    } else {
                        
                        let parameter = ["email":email,
                                         "pw":password,
                                         "nickname":nickName,
                                         "tel":tel,
                                         "joinpath":"EMAIL"]
                        print("@@@@@ \(parameter) @@@@@")
                        
                        Alamofire.request(domain + joinURL, method: .post, parameters: parameter, encoding: URLEncoding.default, headers: nil).response(completionHandler: { (response) in
                            self.parseJoin(JSONData: response.data!)
                        })
                    }
                }
            }
        }
    }
    
    func parseJoin(JSONData: Data){
        do {
            let readableJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! [String:AnyObject]
            print("JSON : \(readableJSON)")
            
            let joinState = readableJSON["result"] as! String
            
            if joinState == "true" {
                
//                basicAlert(target: self, title: nil, message: "joinOK".localized)
                self.dismiss(animated: true, completion: nil)
                
                
            } else {
                
                basicAlert(target: self, title: nil, message: "joinFail".localized)
            }
            
        }catch{
            print("[ Fail ]")
            basicAlert(target: self, title: "회원가입 오류", message: "다시 시도해주세요.")
            print("parse nickname dup check error : \(error)")
        }

    }
    
    @IBAction func backBtn(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension JoinController {
    func intervalCalculator(_ value: CGFloat) -> CGFloat {
        let v = self.view.frame.height - (titleLabel.frame.maxY + completionBtn.frame.height)
//        print("핸드폰 높이 : \(self.view.frame.height)")
//        print("타이틀 maxY : \(titleLabel.frame.maxY)")
//        print("버튼 높이 : \(completionBtn.frame.height)")
//        print("결과 값 : \(v)")
        return (value / 530.5) * v
    }
}

