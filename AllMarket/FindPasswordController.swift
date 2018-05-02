//
//  FindPasswordController.swift
//  AllMarket
//
//  Created by 김민주 on 2017. 11. 3..
//  Copyright © 2017년 MinJu. All rights reserved.
//

import UIKit
import Alamofire

class FindPasswordController: UIViewController {

    @IBOutlet weak var backBtn: UIBarButtonItem!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var tempPwTextField: UITextField!
    @IBOutlet weak var pwTextField: UITextField!
    @IBOutlet weak var pwConfirmTextField: UITextField!
    @IBOutlet weak var completionBtn: UIButton!
    
    var email = ""
    var password = ""
    var tempPassword = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tempPwTextField.isSecureTextEntry = true
        pwTextField.isSecureTextEntry = true
        pwConfirmTextField.isSecureTextEntry = true
        
        navigationTitle(self, "findPWTitle".localized)
        
        backBtn.image = UIImage(named:"backBtn")?.withRenderingMode(.alwaysOriginal)
        completionBtn.backgroundColor = UIColor.init(hex: "051c30")
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 4 {
            moveTextField(textField, moveDistance: -100, up: true)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 4 {
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
    
    //이메일 확인 버튼
    @IBAction func email(_ sender: UIButton) {
        if emailTextField.text == "" {
            basicAlert(target: self, title: nil, message: "emailInput".localized)
            
        }else{
            email = emailTextField.text!
            
            guard isValidEmail(str: email) else {
                basicAlert(target: self, title: nil, message: "notEmail".localized)
                
                return
            }
            
            tempPassword = pwRandom(length: 6)
            let parameter = ["email":email,
                             "pw":tempPassword]
            
            print (" [ email ] : \(email) #### [ pass ] : \(tempPassword)")
            
            Alamofire.request(domain + tmepPassURL, method: .post, parameters: parameter, encoding: URLEncoding.default, headers: nil).response(completionHandler: { (response) in
                basicAlert(target: self, title: nil, message: "sentTempPW".localized)
            })
            
        }
    }
    
    @IBAction func FindPwBtn(_ sender: UIButton) {
        
        if tempPwTextField.text! != tempPassword{
            basicAlert(target: self, title: nil, message: "checkTempPw".localized)
        } else {
            
            if (tempPwTextField.text!.characters.count < 5) && (pwTextField.text!.characters.count < 5) && (pwConfirmTextField.text!.characters.count < 5) {
                
                basicAlert(target: self, title: nil, message: "pwMinimum".localized)
                
            } else {
                
                comparePassword(target: self, passStr1: pwTextField.text!, passStr2: pwConfirmTextField.text!)
                
                password = pwTextField.text!
                
                if let token = UserDefaults.standard.string(forKey: "token") {
                    
                    let parameter = ["email":email,
                                     "newpw":password]
                    print("@@@@@ \(parameter) @@@@@")
                    
                    Alamofire.request(domain + findPassURL, method: .post, parameters: parameter, encoding: URLEncoding.default, headers: nil).response(completionHandler: { (response) in
                        self.parsePassword(JSONData: response.data!)
                        print("@@@@ \(response.data!) @@@@")
                        self.presentingViewController?.dismiss(animated: true)
                    })
                    
                }
                
            }
            
        }
        
    }
    
    func parsePassword(JSONData: Data){
        do{
            let readableJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! [String:AnyObject]
            print("JSON : \(readableJSON)")
            
            print("#### 비밀번호 변경 성공 ####")
            
        }catch{
            print("[ Fail ]")
            print("error : \(error)")
            
        }
    }
    
    //뒤로가기 버튼
    @IBAction func DoneBtn(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
        //        self.navigationController?.popViewController(animated: true)
    }


}
