//
//  FollowerTableController.swift
//  AllMarket
//
//  Created by MAC on 2017. 9. 6..
//  Copyright © 2017년 MinJu. All rights reserved.
//

import UIKit
import Alamofire

class FollowerUser {
    var check: String?
    var cnt: String?
    var img: String?
    var my_follower: String?
    var name: String?
    var user_idx: String?
}

class FollowerTableController: UITableViewController {
    

    @IBOutlet weak var backBtn: UIBarButtonItem!
    
    let user_idx = UserDefaults.standard.string(forKey: "user_idx") as! String

    var followerList = [FollowerUser]()
    
    var userCnt = NSMutableAttributedString()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationTitle(self, "followerTitle".localized)
        
        backBtn.image = UIImage(named:"backBtn")?.withRenderingMode(.alwaysOriginal)
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.tableFooterView?.isHidden = true
        
        self.requestFollowerList()

    }
    
    func requestFollowerList(){
        
        followerList = []
        
        if (UserDefaults.standard.string(forKey: "token") != nil) {
            
            var parameter = ["":""]
            
            if (UserDefaults.standard.object(forKey: "idx") == nil){
                parameter = ["user_idx1":user_idx,
                             "user_idx2":user_idx]
            } else {
                let idx = UserDefaults.standard.object(forKey: "idx") as! String
                parameter = ["user_idx1":user_idx,
                             "user_idx2":idx]
            }
            
            print("parameter : \(parameter)")
            
            Alamofire.request(domain + followerURL, method: .post, parameters: parameter, encoding: URLEncoding.default, headers: nil).response(completionHandler: { (response) in
                self.parseFollower(JSONData: response.data!)
            })
        }
        
    }
    
    func parseFollower(JSONData: Data){
        do {
            let readableJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! [String: AnyObject]
            print("[ Follower JSON ] : \(readableJSON)")
            
            if let followerListJSON = readableJSON["user"] as? Array<AnyObject> {
                for i in 0..<followerListJSON.count {
                    if let followerList = followerListJSON[i] as? [String:AnyObject] {
                        
                        let followerListStore = FollowerUser()
                        followerListStore.check = followerList["check"] as? String
                        followerListStore.cnt = followerList["cnt"] as? String
                        
//                        if let subPath = followerList["img"] as? String {
//                            let imagePath = domain + subPath
//                            print(imagePath)
//
//                            let imageData = try? Data(contentsOf : URL(string: imagePath)!)
//
//                            followerListStore.img = UIImage(data: imageData!)
////                            followerListStore.img.layer.cornerRadius = self.profileImg.bounds.width / 2.0
////                            followerListStore.img.clipsToBounds = true
//                        }
                        
                        let subPath = followerListStore.img = followerList["img"] as? String
                        followerListStore.my_follower = followerList["my_follower"] as? String
                        followerListStore.name = followerList["name"] as? String
                        followerListStore.user_idx = followerList["user_idx"] as? String
                        
                        self.followerList.append(followerListStore)
                    }
                }
                self.tableView.reloadData()
            }
            
        } catch {
            print("[ Follower Error ] : \(error)")
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if followerList.count == 0 {
//            var messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
//
//            messageLabel.text = "팔로워한 사람이 없습니다."
//            //center the text
//            messageLabel.textAlignment = .center
//            //auto size the text
//            messageLabel.sizeToFit()
//
//            tableView.backgroundView = messageLabel
//
//            tableView.separatorStyle = .none
            return 0
        }
        return self.followerList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! FollowerCell
        
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        
        cell.followerList = self.followerList[indexPath.row]
        
        let textFont: [String:AnyObject] = [NSForegroundColorAttributeName: UIColor.init(hex: "989898"), NSFontAttributeName: UIFont.systemFont(ofSize: 12.0)]
        let numberFont: [String:AnyObject] = [NSForegroundColorAttributeName: UIColor.init(hex: "989898"), NSFontAttributeName: UIFont.systemFont(ofSize: 12.0, weight: UIFontWeightMedium)]
        
        let productCnt = followerList[indexPath.row].cnt as! NSString
        let followerCnt = followerList[indexPath.row].my_follower as! NSString
        
        let productCntStyle = NSMutableAttributedString(string: productCnt as String, attributes: numberFont)
        let followerCntStyle = NSMutableAttributedString(string: followerCnt as String, attributes: numberFont)
        
        let product: NSString = "ItemsCnt".NSlocalized as NSString
        let follower: NSString = "followerCnt".NSlocalized as NSString
        
        let productStyle = NSMutableAttributedString(string: product as String, attributes: textFont)
        let followerStyle = NSMutableAttributedString(string: follower as String, attributes: textFont)
        
        productStyle.append(productCntStyle)
        productStyle.append(followerStyle)
        productStyle.append(followerCntStyle)
        
        cell.userCnt.attributedText = productStyle
        
        if followerList[indexPath.row].user_idx != user_idx{
            if followerList[indexPath.row].check == "true" {
                //팔로잉 되어있음 - 맞팔 - 언팔할 수 있음 - 팔로잉->팔로우
                cell.followBtn.setImage(UIImage(named: "following"), for: .normal)
                
                cell.followBtn.addTarget(self, action: #selector(unfollowAction(sender:)), for: .touchUpInside)
                cell.followBtn.tag = indexPath.row
            }
            else if followerList[indexPath.row].check == "false" {
                //팔로잉 안 되어 있음 - 팔로우 할 수 있음 - 팔로우->팔로잉
                cell.followBtn.setImage(UIImage(named: "follow"), for: .normal)
                
                cell.followBtn.addTarget(self, action: #selector(followAction(sender:)), for: .touchUpInside)
                cell.followBtn.tag = indexPath.row
            }
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(profileTapped(tapGestureRecognizer:)))
        cell.isUserInteractionEnabled = true
        cell.addGestureRecognizer(tap)
        cell.tag = indexPath.item
        
        return cell
    }
    
    //MARK: - Go Profile Action
    var selectedUser = ""
    
    func profileTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        let view = tapGestureRecognizer.view
        let index = view?.tag
        
        selectedUser = followerList[index!].user_idx!
        
        print("selectedUser : \(selectedUser)")
        
        if selectedUser == user_idx {
            
            changeView(target: self, identifier: "ProfileHome")
            
        } else {
            
            UserDefaults.standard.set(selectedUser, forKey: "idx")
            UserDefaults.standard.set(followerList[index!].name!, forKey: "user_name")
//            changeView(target: self, identifier: "UserProfile")
            changeView(target: self, identifier: "UserProfileTableController")
            
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    
    //팔로우 취소
    func unfollowAction(sender: UIButton) {

        sender.isSelected = !sender.isSelected

        if sender.isSelected {
            print("팔로우 취소")
            
            let del_idx = followerList[sender.tag].user_idx!
            let nick = followerList[sender.tag].name!
            delFollow(nick: nick, del_idx: del_idx, sender: sender)
            
            
        } else {
            print("팔로잉")
            
            let add_idx = followerList[sender.tag].user_idx!
            addFollow(add_idx: add_idx, sender: sender)
            
            
        }
    }
    
    //팔로잉
    func followAction(sender: UIButton) {
        sender.isSelected = !sender.isSelected

        if sender.isSelected {
            print("팔로잉")
            
            let add_idx = followerList[sender.tag].user_idx!
            addFollow(add_idx: add_idx, sender: sender)
            
            
        } else {
            print("팔로우 취소")
            
            let del_idx = followerList[sender.tag].user_idx!
            let nick = followerList[sender.tag].name!
            delFollow(nick: nick, del_idx: del_idx, sender: sender)
            
        }
    }
    
    //팔로우 추가
    func addFollow(add_idx: String, sender: UIButton) {
        let parameter = ["user_idx":user_idx,
                         "add_idx":add_idx]
        
        Alamofire.request(domain + addFollowerURL, method: .post, parameters: parameter, encoding: URLEncoding.default, headers: nil).response { (response) in
            do {
                let readableJSON = try JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) as! [String: AnyObject]
                print(readableJSON)
                
                let followState = readableJSON["result"] as! String
                if followState == "true" {
                    
                    print("image : following")
                    
                    
                }else{
                    print("follow fail : \(followState)")
                }
                
                
            }catch{
                print("parse follow error: \(error)")
            }
//            self.tableView.reloadData()
        }
        sender.setImage(UIImage(named: "following"), for: .normal)
    }
    
    //팔로우 삭제
    func delFollow(nick: String, del_idx: String, sender: UIButton) {
        let parameter = ["user_idx":user_idx,
                         "del_idx":del_idx]
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        var attributedText: NSMutableAttributedString!
        
        if L102Language.currentAppleLanguage() == "ko" {
            attributedText = NSMutableAttributedString(
                string: "'\(nick)'님의 소식을 끊겠습니까?",
                attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14),
                             NSForegroundColorAttributeName: UIColor.darkGray])
            
        } else {
            attributedText = NSMutableAttributedString(
                string: "Unfollow '\(nick)'?",
                attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14),
                             NSForegroundColorAttributeName: UIColor.darkGray])
            
        }
        
        alertController.setValue(attributedText, forKey: "attributedTitle")
        
        let severAction = UIAlertAction(title: "unfollow".localized, style: .destructive) { (action) in
            
            let parameter = ["user_idx":self.user_idx,
                             "delete_idx":del_idx]
            print("parameter : \(parameter)")
            
            Alamofire.request(domain + delFollowerURL, method: .post, parameters: parameter, encoding: URLEncoding.default, headers: nil).response { (response) in
                do {
                    let readableJSON = try JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) as! [String: AnyObject]
                    print(readableJSON)
                    
                    let followState = readableJSON["result"] as! String
                    if followState == "true" {
                        
                        print("image : follow")
                        
                    }else{
                        print("sever fail : \(followState)")
                    }
                    
                }catch{
                    print("parse sever error: \(error)")
                }
//                self.tableView.reloadData()
            }
            sender.setImage(UIImage(named: "follow"), for: .normal)
        }
        let cancelAction = UIAlertAction(title: "cancelTitle".localized, style: .cancel, handler: nil)
        
        alertController.addAction(severAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }

    
    @IBAction func DoneBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
//        self.dismiss(animated: true, completion: nil)
    }

}
