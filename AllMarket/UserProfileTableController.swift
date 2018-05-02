//
//  UserProfileTableController.swift
//  AllMarket
//
//  Created by 김민주 on 2017. 11. 29..
//  Copyright © 2017년 MinJu. All rights reserved.
//

import UIKit
import Alamofire

class UserProfileTableController: UITableViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var nicknameLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var productLabel: UILabel!
    @IBOutlet weak var followerLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    
    @IBOutlet weak var itemFixed: UILabel!
    @IBOutlet weak var followerFixed: UILabel!
    @IBOutlet weak var followingFixed: UILabel!
    
    @IBOutlet weak var itemBtn: UIButton!
    @IBOutlet weak var followerBtn: UIButton!
    @IBOutlet weak var followingBtn: UIButton!
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var guideView: UIView!
    
    @IBOutlet weak var firstLine: UIView!
    @IBOutlet weak var secondLine: UIView!
    
    @IBOutlet weak var nickNameInterval: NSLayoutConstraint!
    
    var finalDate = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            if UIScreen.main.nativeBounds.height != 2436 {
                tableView.contentInsetAdjustmentBehavior = .never
            } else {
                tableView.contentInsetAdjustmentBehavior = .always
            }
            
        } else if #available(iOS 10.0, *) {
            
            backBtn.frame.origin.y = 14
            nickNameInterval.constant = 20
        }
        
        let width = self.view.frame.width / 3
        let labelY = self.guideView.frame.height - 72.0
        let fixedLabelY = self.guideView.frame.height - 52.0
        let btnY = self.guideView.frame.height - 84
        let lineY = self.guideView.frame.height - 64.0
        
        print("profile labelY: \(self.guideView.frame.height)")
        print("profile labelY: \(labelY)")
        
        productLabel.frame = CGRect(x: 0, y: labelY, width: width, height: 16)
        followerLabel.frame = CGRect(x: width, y: labelY, width: width, height: 16)
        followingLabel.frame = CGRect(x: width * 2, y: labelY, width: width, height: 16)
        
        itemFixed.frame = CGRect(x: 0, y: fixedLabelY, width: width, height: 16)
        followerFixed.frame = CGRect(x: width, y: fixedLabelY, width: width, height: 16)
        followingFixed.frame = CGRect(x: width * 2, y: fixedLabelY, width: width, height: 16)
        
        itemBtn.frame = CGRect(x: 0, y: btnY, width: width, height: 84)
        followerBtn.frame = CGRect(x: width, y: btnY, width: width, height: 84)
        followingBtn.frame = CGRect(x: width * 2, y: btnY, width: width, height: 84)
        
        firstLine.frame = CGRect(x: width, y: lineY, width: 1, height: 18)
        secondLine.frame = CGRect(x: width * 2, y: lineY, width: 1, height: 18)
        
        self.tabBarController?.tabBar.isHidden = false
        
        guideView.backgroundColor = UIColor.init(hex: "051c30")
        
        self.addRefreshControl()
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.tableFooterView?.isHidden = true
        self.tableView.backgroundColor = UIColor.init(hex: "ffffff")
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if let selectionIndexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: selectionIndexPath, animated: true)
        }
        
        requestUserInfo()
        
        // LoginViewController에서만 네비게이션바 안 보이게
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        // 다른 뷰에선 네비게이션바 보이게
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
    
    func requestUserInfo(){
        if (UserDefaults.standard.string(forKey: "token") != nil) {
            
            if (UserDefaults.standard.object(forKey: "idx") != nil){
                let idx = UserDefaults.standard.object(forKey: "idx") as! String
                let parameter = ["user_idx":idx]
                print("parameter : \(parameter)")
                
                Alamofire.request(domain + profileMainURL,
                                  method: .post,
                                  parameters: parameter,
                                  encoding: URLEncoding.default,
                                  headers: nil).response(completionHandler: { (response) in
                                    self.parseUserInfo(JSONData: response.data!)
                })
            }
        }
    }
    
    func parseUserInfo(JSONData: Data){
        do{
            let readableJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! [String:AnyObject]
            print("JSON : \(readableJSON)")
                
//            {"profile_image":null,"nickname":null,"myItem":"0","date":null,"email":null,"tel":null,"follower":"0","following":"0","tel_view":null}
            
            if let subPath = readableJSON["profile_image"] as? String {
                let imagePath = domain + subPath
                print(imagePath)
                
                let imageData = try? Data(contentsOf : URL(string: imagePath)!)
                
                self.profileImg.image  = UIImage(data: imageData!)
                self.profileImg.layer.cornerRadius = self.profileImg.bounds.width / 2.0
                self.profileImg.clipsToBounds = true
            }
            
            if let nickName = readableJSON["nickname"] as? String {
                nicknameLabel.text = nickName
            }
            if let myItem = readableJSON["myItem"] as? String {
                productLabel.text = myItem
            }
            if let date = readableJSON["date"] as? String {
                self.subStringDate(date: date)
                
                dateLabel.text = finalDate
            }
            if let follower = readableJSON["follower"] as? String {
                followerLabel.text = follower
            }
            if let following = readableJSON["following"] as? String {
                followingLabel.text = following
            }
            
        }catch{
            print(" #### [ Profile error ] : \(error) #### ")
        }
        
    }
    
    func subStringDate(date: String) {
        
        if L102Language.currentAppleLanguage() == "ko" {
            
            let index = date.index(date.startIndex, offsetBy: 4)
            var year = date.substring(to: index)
            year += "년 "
            
            var start = date.index(date.startIndex, offsetBy: 5)
            var end = date.index(date.endIndex, offsetBy: -12)
            var range = start..<end
            
            var month = date.substring(with: range)
            month += "월 "
            
            start = date.index(date.startIndex, offsetBy: 8)
            end = date.index(date.endIndex, offsetBy: -9)
            range = start..<end
            
            var day = date.substring(with: range)
            day += "일"
            
            finalDate = "가입일 " + year + month + day
            
        } else {
            
            let index = date.index(date.startIndex, offsetBy: 4)
            var year = date.substring(to: index)
            
            var start = date.index(date.startIndex, offsetBy: 5)
            var end = date.index(date.endIndex, offsetBy: -12)
            var range = start..<end
            
            var month = date.substring(with: range)
            month += "/"
            
            start = date.index(date.startIndex, offsetBy: 8)
            end = date.index(date.endIndex, offsetBy: -9)
            range = start..<end
            
            var day = date.substring(with: range)
            day += "/"
            
            if L102Language.currentAppleLanguage() == "en" {
                finalDate = "Join Date " + day + month + year
            } else if L102Language.currentAppleLanguage() == "vi" {
                finalDate = "Ngày tham gia " + day + month + year
            }
            
        }
    }
    
    @IBAction func producAction(_ sender: UIButton) {
        changeView(target: self, identifier: "MyItem")
    }
    
    @IBAction func followerAction(_ sender: UIButton) {
        
        let Follower = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Follower") as! FollowerTableController
        self.navigationController?.pushViewController(Follower, animated: true)
    }
    
    @IBAction func followingAction(_ sender: UIButton) {
        
        let Following = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Following") as! FollowingTableController
        self.navigationController?.pushViewController(Following, animated: true)
    }
    
    @IBAction func DoneBtn(_ sender: UIButton) {
        UserDefaults.standard.removeObject(forKey: "user_name")
        UserDefaults.standard.removeObject(forKey: "idx")
        self.dismiss(animated: true, completion: nil)
    }
    
    func addRefreshControl(){
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshWebView(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    func refreshWebView(_ sender: UIRefreshControl) {
        requestUserInfo()
        sender.endRefreshing()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    

}
