//
//  FollowingTableController.swift
//  AllMarket
//
//  Created by MAC on 2017. 9. 6..
//  Copyright © 2017년 MinJu. All rights reserved.
//

import UIKit
import Alamofire

class FollowingUser {
    var check: String?
    var cnt: String?
    var img: String?
    var my_follower: String?
    var name: String?
    var user_idx: String?
}

class FollowingTableController: UITableViewController {

    @IBOutlet weak var backBtn: UIBarButtonItem!
    @IBOutlet weak var followBtn: UIButton!
    
    let user_idx = UserDefaults.standard.object(forKey: "user_idx") as! String
    
    var followingList = [FollowingUser]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backBtn.image = UIImage(named:"backBtn")?.withRenderingMode(.alwaysOriginal)
        
        if L102Language.currentAppleLanguage() == "ko" {
            navigationTitle(self, "팔로잉")
        } else if L102Language.currentAppleLanguage() == "en" {
            navigationTitle(self, "Following")
        } else if L102Language.currentAppleLanguage() == "vi" {
            navigationTitle(self, "Tiếp theo")
        }
        
        navigationTitle(self, "followingTitle".localized)
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.tableFooterView?.isHidden = true
        
        self.requestFollowingList()

    }
    
    func requestFollowingList(){
        
        followingList = []
        
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
            
            Alamofire.request(domain + followingURL, method: .post, parameters: parameter, encoding: URLEncoding.default, headers: nil).response(completionHandler: { (response) in
                self.parseFollowing(JSONData: response.data!)
            })
        }
    }
    
    func parseFollowing(JSONData: Data){
        do {
            let readableJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! [String: AnyObject]
            print("[ Following JSON ] : \(readableJSON)")
            
            if let followingListJSON = readableJSON["user"] as? Array<AnyObject> {
                for i in 0..<followingListJSON.count {
                    if let followingList = followingListJSON[i] as? [String:AnyObject] {
                        
                        let followingListStore = FollowingUser()
                        followingListStore.check = followingList["check"] as? String
                        followingListStore.cnt = followingList["cnt"] as? String
                        followingListStore.img = followingList["img"] as? String
                        followingListStore.my_follower = followingList["my_follower"] as? String
                        followingListStore.name = followingList["name"] as? String
                        followingListStore.user_idx = followingList["user_idx"] as? String
                        
                        self.followingList.append(followingListStore)
                    }
                }
                tableView.reloadData()
            }
            
            
        } catch {
            print("[ Following Error ] : \(error)")
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if followingList.count == 0 {
            return 0
        }
        return self.followingList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! FollowingCell
        
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        
        cell.followingList = self.followingList[indexPath.row]
        
        let textFont: [String:AnyObject] = [NSForegroundColorAttributeName: UIColor.init(hex: "989898"), NSFontAttributeName: UIFont.systemFont(ofSize: 12.0)]
        let numberFont: [String:AnyObject] = [NSForegroundColorAttributeName: UIColor.init(hex: "989898"), NSFontAttributeName: UIFont.systemFont(ofSize: 12.0, weight: UIFontWeightMedium)]
        
        let productCnt = followingList[indexPath.row].cnt as! NSString
        let followerCnt = followingList[indexPath.row].my_follower as! NSString
        
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
        
        if followingList[indexPath.row].user_idx != user_idx{
            if followingList[indexPath.row].check == "true" {
                cell.followBtn.setImage(UIImage(named: "following"), for: .normal)
                
                cell.followBtn.addTarget(self, action: #selector(unfollowAction(sender:)), for: .touchUpInside)
                cell.followBtn.tag = indexPath.row
            }
            else if followingList[indexPath.row].check == "false" {
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
    
    var selectedUser = ""
    
    func profileTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        let view = tapGestureRecognizer.view
        let index = view?.tag
        
        selectedUser = followingList[index!].user_idx!
        
        print("selectedUser : \(selectedUser)")
        
        if selectedUser == user_idx {

            changeView(target: self, identifier: "ProfileHome")

        } else {
        
            UserDefaults.standard.set(selectedUser, forKey: "idx")
            UserDefaults.standard.set(followingList[index!].name!, forKey: "user_name")
//            changeView(target: self, identifier: "UserProfile")
            changeView(target: self, identifier: "UserProfileTableController")
            
        }
    }
    
    //팔로우 취소
    func unfollowAction(sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            
            let del_idx = followingList[sender.tag].user_idx!
            let nick = followingList[sender.tag].name!
            delFollow(nick: nick, del_idx: del_idx, sender: sender)
            
            
        } else {
            
            let add_idx = followingList[sender.tag].user_idx!
            addFollow(add_idx: add_idx, sender: sender)
            
        }
    }
    
    //팔로잉
    func followAction(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            
            let add_idx = followingList[sender.tag].user_idx!
            addFollow(add_idx: add_idx, sender: sender)
            
        } else {
            
            let del_idx = followingList[sender.tag].user_idx!
            let nick = followingList[sender.tag].name!
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
            }
            sender.setImage(UIImage(named: "follow"), for: .normal)
        }
        let cancelAction = UIAlertAction(title: "cancelTitle".localized, style: .cancel, handler: nil)
        
        alertController.addAction(severAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    
    @IBAction func DoneBtn(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
//        self.dismiss(animated: true, completion: nil)
    }

}
