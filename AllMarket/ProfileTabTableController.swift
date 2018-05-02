//
//  ProfileTabTableController.swift
//  AllMarket
//
//  Created by MAC on 2017. 9. 4..
//  Copyright © 2017년 MinJu. All rights reserved.
//

import UIKit
import Alamofire

class ProfileTabTableController: UITableViewController {

    @IBOutlet weak var languageReSetting: UILabel!
    @IBOutlet weak var userNickName: UILabel!
    @IBOutlet weak var profileImg: UIImageView!
    
    let myData = UserDefaults.standard
    let user_idx = UserDefaults.standard.string(forKey: "user_idx") as! String
    
    var alertTitle = ""
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.tabBarController?.tabBar.isHidden = false
        
        if let selectionIndexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: selectionIndexPath, animated: true)
        }
        
        requestUserInfo()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationTitle(self, "profileTitle".localized)
        
        if myData.object(forKey: "selectLanguage") != nil {
            languageReSetting.text = myData.object(forKey: "selectLanguage") as! String
        }
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.tableFooterView?.isHidden = true
        self.tableView.backgroundColor = UIColor.init(hex: "ececec")

    }
    
    func requestUserInfo(){
        if (UserDefaults.standard.string(forKey: "token") != nil) {
            
            let parameter = ["user_idx":user_idx]
            
            Alamofire.request(domain + profileMainURL, method: .post, parameters: parameter, encoding: URLEncoding.default, headers: nil).response(completionHandler: { (response) in
                self.parseUserInfo(JSONData: response.data!)
            })
        }
    }
    
    func parseUserInfo(JSONData: Data){
        do{
            let readableJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! [String:AnyObject]
            print("JSON : \(readableJSON)")
            
            //{"profile_image":null,"nickname":null,"myItem":"0","date":null,"email":null,"tel":null,"follower":"0","following":"0","tel_view":null}
            
//            if let profileImageUrl = readableJSON["profile_image"] as? String {
//                if profileImageUrl != "" {
//
//                    let url = URL(string: profileImageUrl)!
//                    self.profileImg.kf.setImage(with: url)
//
//                }else{
//                    self.profileImg.image = UIImage(named: "p_profile")
//                }
//
//            }
            
            if let subPath = readableJSON["profile_image"] as? String {
                let imagePath = domain + subPath
                print(imagePath)
                
                let imageData = try? Data(contentsOf : URL(string: imagePath)!)
                
                self.profileImg.image  = UIImage(data: imageData!)
                self.profileImg.layer.cornerRadius = self.profileImg.bounds.width / 2.0
                self.profileImg.clipsToBounds = true
            }
            
            if let nickName = readableJSON["nickname"] as? String {
                userNickName.text = nickName
            }
        }catch{
            print(" #### [ pofile error ] : \(error) #### ")
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0{
            return 6
        }
        return 4
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        
        let storyboard: UIStoryboard = self.storyboard!
        
        if section == 0 {
            if row == 0 {
                print("내 프로필 홈으로 가기")
                
                changeView(target: self, identifier: "ProfileHome")
                
            } else if row == 1 {
                
                print("나의 상품")
                
                changeView(target: self, identifier: "MyItem")
            
            } else if row == 2 {
                
                print("찜한 상품")
                
                changeView(target: self, identifier: "steamItem")

            } else if row == 3 {
                
                print("댓글 관리")
                
//                changeView(target: self, identifier: "Comment")
                let Comment = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Comment") as! CommentTableController
                self.navigationController?.pushViewController(Comment, animated: true)
                
            } else if row == 4 {
                
                print("푸시 알림 설정")
                
                let PushNotice = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PushNotice") as! PushNoticeTableController
                self.navigationController?.pushViewController(PushNotice, animated: true)
                
                
            } else if row == 5 {
                print("질문하기")
                
                changeView(target: self, identifier: "WKQuestion")
            }

        } else if section == 1 {
            if row == 0 {
                print("프로그램 정보")
                
                let ProgramInfo = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProgramInfo") as! ProgramInfoTableController
                self.navigationController?.pushViewController(ProgramInfo, animated: true)
                
//                changeView(target: self, identifier: "ProgramInfo")
            } else if row == 1 {
                print("언어 선택")
                
                myData.removeObject(forKey: "selectLanguage")
                myData.removeObject(forKey: "selectLanguageEng")
                
               changeRootVC("Language")
                
            } else if row == 2 {
                print("로그아웃")
                
                //자동로그인 해제
                disableAutoLogin()
                let parameter = ["user_idx":user_idx]
                Alamofire.request(domain + logoutURL, method: .post, parameters: parameter, encoding: URLEncoding.default, headers: nil)
                
                changeRootVC("LoginView")
                
            } else if row == 3 {
                print("회원탈퇴")
                
                let alert = UIAlertController(title: "withdrawalConfirm".localized, message: nil, preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "okTitle".localized, style: .default){
                    (_) in
                    
                    //회원 아이디랑 비번 지우기
                    self.secession()
                    
                    let myData = UserDefaults.standard
                    myData.removeObject(forKey: "selectLanguage")
                    myData.removeObject(forKey: "selectLanguageEng")
                    myData.removeObject(forKey: "facebookEmail")
                    myData.removeObject(forKey: "email")
                    myData.removeObject(forKey: "pass")
                    myData.removeObject(forKey: "user_idx")
                    
                    self.resetDefaults()
                    
                    self.changeRootVC("Language")
                }
                
                let cancelAction = UIAlertAction(title: "cancelTitle".localized, style: .cancel){
                    (_) in
                    
                    _ = self.navigationController?.popViewController(animated: true)
                    
                }
                
                alert.addAction(okAction)
                alert.addAction(cancelAction)
                
                self.present(alert, animated: false, completion: nil)
                
            }
        }
        
    }
    
    private func changeRootVC(_ stroyboard: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewContoller = storyboard.instantiateViewController(withIdentifier: stroyboard)
        
        var option = UIWindow.TransitionOptions(direction: .toTop, style: .easeInOut)
        option.duration = 0.5
        UIApplication.shared.keyWindow?.setRootViewController(viewContoller, options: option)
        
//        if let appdelegate = UIApplication.shared.delegate as? AppDelegate {
//            appdelegate.window?.rootViewController = loginViewContoller
//        }
    }
    
    //Header Title
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if( section == 0 ) {
            return ""
        } else {
            return "   "
        }
    }
    
    //Header Height
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if( section == 0 ) {
            return 0
        } else {
            return 28
        }
    }
    
    //Header Color
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 28))
        headerView.backgroundColor = UIColor.init(hex: "ececec")
        return headerView
    }
    
    //로그아웃
    func disableAutoLogin() {
        let myData : UserDefaults = UserDefaults.standard
        
        //저장되어 있던 이메일, 비밀번호 값 삭제
        myData.removeObject(forKey: "facebookEmail")
        myData.removeObject(forKey: "email")
        myData.removeObject(forKey: "pass")
        myData.removeObject(forKey: "user_idx") 
        
        if myData.object(forKey: "email") == nil{
            if myData.object(forKey: "pass") == nil{
                print("@@@@@ email, pass remove success @@@@@")
            }
        }
    }
    
    //회원탈퇴
    func secession() {
        let parameter = ["user_idx":user_idx]
        
        Alamofire.request(domain + secessionURL,
                          method: .post,
                          parameters: parameter,
                          encoding: URLEncoding.default,
                          headers: nil).response(completionHandler: {
                            (response) in
                            
                            do{
                                let readableJSON = try JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) as! [String : AnyObject]
                                
                                let secession = readableJSON["result"] as! String
                                
                                if secession == "true" {
                                    print("#### 회원 탈퇴 성공 #####")
                                }
                            } catch {
                                print("#### 회원 탈퇴 실패 #####")
                            }
                            
                          })
    }
    
    func resetDefaults() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }
}
