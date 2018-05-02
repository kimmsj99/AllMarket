//
//  ViewController.swift
//  AllMarket
//
//  Created by MAC on 2017. 8. 9..
//  Copyright © 2017년 MinJu. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import Alamofire
import NVActivityIndicatorView

//로그인 페이지
class LoginController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var amLogo: UIImageView!
    @IBOutlet weak var guideView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var pwTextField: UITextField!
    @IBOutlet weak var autoLoginBtn: UIButton!
    @IBOutlet weak var findPW: UIButton!
    
    let activityData = ActivityData()
    
    var tfemail = ""
    var tfpass = ""
    
    let myData = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        guideView.backgroundColor = UIColor.init(hex: "051c30")
        
        addToolBar(target: self.view, textField: emailTextField)
        addToolBar(target: self.view, textField: pwTextField)
        
        pwTextField.isSecureTextEntry = true
        
        autoLoginBtn.setImage(UIImage(named: "m_autoLogin"), for: .normal)
        
        findPW.addTarget(self, action: #selector(findPass(_:)), for: .touchUpInside)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(noti:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(noti:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        scrollView.contentSize = contentView.frame.size
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if UserDefaults.standard.object(forKey: "user_idx") != nil {
            changeView(target: self, identifier: "Home")
        }
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
    
    //자동로그인 버튼
    @IBAction func autoLogin(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            autoLoginBtn.setImage(UIImage(named: "m_autoLoginSel"), for: .normal)
            
            tfemail = emailTextField.text!
            tfpass = pwTextField.text!
            
        } else {
            autoLoginBtn.setImage(UIImage(named: "m_autoLogin"), for: .normal)
            
            myData.removeObject(forKey: "email")
            myData.removeObject(forKey: "pass")
            if myData.object(forKey: "email") == nil {
                if myData.object(forKey: "pass") == nil {
                    print("Auto Login Cancel")
                }
            }
        }
        
    }
    
    //로그인 버튼
    @IBAction func LoginBtn(_ sender: UIButton) {
        
        if (emailTextField == nil || emailTextField.text == "") {
            basicAlert(target: self, title: nil, message: "emailInput".localized)
            
        } else {
            if (pwTextField == nil || pwTextField.text == "" ) {
              basicAlert(target: self, title: nil, message: "pwInput".localized)
            
            } else {
                
                tfemail = emailTextField.text!
                tfpass = pwTextField.text!
                
                if autoLoginBtn.isSelected {
                    
                    myData.set(tfemail, forKey: "email")
                    myData.set(tfpass, forKey: "pass")
                    
                }
                
                self.loginPath()
                
            }
        }
    }
    
    func loginPath(){
            if let token = myData.string(forKey: "token") {
                
                let language = myData.string(forKey: "selectLanguageEng")!
                
                var parameter = ["":""]
                
                if myData.object(forKey: "facebookEmail") != nil {
                    tfemail = myData.object(forKey: "facebookEmail") as! String
                    tfpass = "facebook@login"
                    parameter = ["email":tfemail,
                                 "pw":tfpass,
                                 "lang":language,
                                 "token":token,
                                 "device":"1"]
                } else {
                    parameter = ["email":tfemail,
                                 "pw":tfpass,
                                 "lang":language,
                                 "token":token,
                                 "device":"1"]
                }
                print("[ parameter ] : \(parameter)")
                
                Alamofire.request(domain + loginURL,
                                  method: .post,
                                  parameters: parameter,
                                  encoding: URLEncoding.default,
                                  headers: nil).response(completionHandler: { (response) in
                                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                                    NVActivityIndicatorPresenter.sharedInstance.startAnimating(self.activityData)
                                    self.parseLogin(JSONData: response.data!)
                                  })
            }
        
    }
    
    func parseLogin(JSONData: Data) {
        do{
            let readableJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! [String:AnyObject]
            print("JSON : \(readableJSON)")
            
            let loginState = readableJSON["result"] as! String
            
            if loginState == "true" {
                //로그인 성공
                
                myData.set(readableJSON["user_idx"], forKey: "user_idx")
                myData.set(readableJSON["menu"], forKey: "menu")
                myData.set(pwTextField.text!, forKey: "existing_pw")
                myData.set(readableJSON["warning"], forKey: "blackMem")
                myData.set(readableJSON["joinpath"], forKey: "joinpath")
                print("@@@@ \(myData.object(forKey: "user_idx")!) @@@@")
                print("@@@@ \(myData.object(forKey: "menu")!) @@@@")
                
                print("@@@@ Login Success @@@@")
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                changeView(target: self, identifier: "Home")
    
            }else{
                //로그인 실패
                basicAlert(target: self, title: "loginFail".localized, message: "again".localized)
            }
            
        }catch{
            print(" error \(error)")
            basicAlert(target: self, title: "로그인 실패", message: "다시 시도해주세요")
        }
    }

    
    //facebook으로 로그인
    @IBAction func facebookLogin(_ sender: UIButton) {
        let fbLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["public_profile", "email", "user_friends"], from: self) { (result, error) in
            if(error == nil){
                let fbloginresult: FBSDKLoginManagerLoginResult = result!
                if fbloginresult.grantedPermissions == nil {
                    return
                } else if (fbloginresult.grantedPermissions.contains("email")){
                    self.getFBUserData()
                }
            }
        }
    }
    
    func getFBUserData() {
        if((FBSDKAccessToken.current()) != nil) {
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "email, name"]).start(completionHandler: { (connection, result, error) -> Void in
                if(error == nil){
                    print("result \(result!)")
                    let res = result as! [String : AnyObject]
                    let email = res["email"] as! String
                    print("email : \(email)")
                    
                    self.myData.set(email, forKey: "facebookEmail")
                    let parameter = ["email":email]
                    
                    Alamofire.request(domain + facebookCheckURL,
                                      method: .post,
                                      parameters: parameter,
                                      encoding: URLEncoding.default,
                                      headers: nil).response(completionHandler: { (response) in
                        do {
                            let readableJSON = try JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) as! [String : AnyObject]
                            
                            print("페이스북 readableJSON : \(readableJSON)")
                            
                            let facebookCehck = readableJSON["result"] as! String
                            
                            if facebookCehck == "false" {
                                
                                changeView(target: self, identifier: "FBJoin")
                                
                            } else {
                                self.myData.set(email, forKey: "email")
                                self.myData.set("facebook@login", forKey: "pass")
                                self.loginPath()
                            }
                            
                        } catch {
                            basicAlert(target: self, title: nil, message: "회원가입 실패")
                        }
                        
                    })
                    
                }
            }
        )}
    }
    
    func findPass(_ sender: UIButton) {
        changeView(target: self, identifier: "FindPW")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
