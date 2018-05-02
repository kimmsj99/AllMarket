//
//  PushNoticeTableController.swift
//  AllMarket
//
//  Created by 김민주 on 2017. 9. 19..
//  Copyright © 2017년 MinJu. All rights reserved.
//

import UIKit
import Alamofire

class PushNoticeTableController: UITableViewController {
    
    @IBOutlet weak var backBtn: UIBarButtonItem!
    
    @IBOutlet weak var allSwitch: UISwitch!
    @IBOutlet weak var commentSwitch: UISwitch!
    @IBOutlet weak var followSwitch: UISwitch!
    @IBOutlet weak var newProductSwitch: UISwitch!
    @IBOutlet weak var messageSwitch: UISwitch!
    
    let token = UserDefaults.standard.object(forKey: "token") as! String
    let user_idx = UserDefaults.standard.object(forKey: "user_idx") as! String
    
    let myData = UserDefaults.standard
    
    var all = ""
    var comment = ""        //true or false 값
    var follow = ""
    var newProduct = ""
    var message = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.isHidden = true
        
//        if L102Language.currentAppleLanguage() == "ko" {
//            navigationTitle(self, "푸시 알림 설정")
//        } else if L102Language.currentAppleLanguage() == "en" {
//            navigationTitle(self, "Push notification settings")
//        } else if L102Language.currentAppleLanguage() == "vi" {
//            navigationTitle(self, "Đẩy cài đặt thông báo")
//        }
        
        navigationTitle(self, "pushAlertType".localized)
        
        backBtn.image = UIImage(named:"backBtn")?.withRenderingMode(.alwaysOriginal)
        
        self.requestPushCheck()
        
        allSwitch.isOn = myData.bool(forKey: "all")
        commentSwitch.isOn = myData.bool(forKey: "push1")
        followSwitch.isOn = myData.bool(forKey: "push2")
        newProductSwitch.isOn = myData.bool(forKey: "push3")
        messageSwitch.isOn = myData.bool(forKey: "push4")
        
        all = String(myData.bool(forKey: "all"))
        comment = String(myData.bool(forKey: "push1"))
        follow = String(myData.bool(forKey: "push2"))
        newProduct = String(myData.bool(forKey: "push3"))
        message = String(myData.bool(forKey: "push4"))
        
        allPushOff()
    
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.tableFooterView?.isHidden = true
        
        self.tableView.backgroundColor = UIColor.init(hex: "ececec")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if let selectionIndexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: selectionIndexPath, animated: true)
        }
    }
    
    func requestPushCheck(){
        if (UserDefaults.standard.string(forKey: "token") != nil) {
            
            let parameter = ["user_idx":user_idx]
            
            Alamofire.request(domain + pushCheckURL, method: .post, parameters: parameter, encoding: URLEncoding.default, headers: nil).response(completionHandler: { (response) in
                self.parsePushCheck(JSONData: response.data!)
            })
        }
    }
    
    func parsePushCheck(JSONData: Data) {
        do {
            let readableJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! [String:AnyObject]
            print("pushCheckJSON : \(readableJSON)")
            
        } catch {
            print("pushCheck JSON Parse Error : \(error)")
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
            return 1
        }
        return 4
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont.systemFont(ofSize: 12.0)
        header.textLabel?.textColor = UIColor.init(hex: "454545")
    }
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let footer = view as! UITableViewHeaderFooterView
        footer.textLabel?.font = UIFont.systemFont(ofSize: 12.0)
        footer.textLabel?.textColor = UIColor.init(hex: "454545")
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            return("")
        }
        return ("pushType".localized)
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0{
            return ("  ")
        }
        return ""
    }
    
    func allPushOff(){
        
        if myData.bool(forKey: "push1") == false && myData.bool(forKey: "push2") == false && myData.bool(forKey: "push3") == false && myData.bool(forKey: "push4") == false {
            allSwitch.setOn(false, animated: true)
        }
        
    }
    
    @IBAction func allPush(_ sender: UISwitch) {
        
        myData.set(sender.isOn, forKey: "all")
        
        if sender.isOn{
            commentSwitch.setOn(true, animated: true)
            followSwitch.setOn(true, animated: true)
            newProductSwitch.setOn(true, animated: true)
            messageSwitch.setOn(true, animated: true)
            
            myData.set(commentSwitch.isOn, forKey: "push1")
            comment = String(myData.bool(forKey: "push1"))
            
            myData.set(followSwitch.isOn, forKey: "push2")
            follow = String(myData.bool(forKey: "push2"))
            
            myData.set(sender.isOn, forKey: "push3")
            newProduct = String(myData.bool(forKey: "push3"))
            
            myData.set(messageSwitch.isOn, forKey: "push4")
            message = String(myData.bool(forKey: "push4"))
            
        } else {
            commentSwitch.setOn(false, animated: true)
            followSwitch.setOn(false, animated: true)
            newProductSwitch.setOn(false, animated: true)
            messageSwitch.setOn(false, animated: true)
            
            myData.set(commentSwitch.isOn, forKey: "push1")
            comment = String(myData.bool(forKey: "push1"))
            
            myData.set(followSwitch.isOn, forKey: "push2")
            follow = String(myData.bool(forKey: "push2"))
            
            myData.set(sender.isOn, forKey: "push3")
            newProduct = String(myData.bool(forKey: "push3"))
            
            myData.set(messageSwitch.isOn, forKey: "push4")
            message = String(myData.bool(forKey: "push4"))

        }
        
        changePush()
        
    }
    
    @IBAction func commentPush(_ sender: UISwitch) {
        
        myData.set(sender.isOn, forKey: "push2")
        
        if sender.isOn{
            
//            sender.isOn = myData.bool(forKey: "push1")
            allSwitch.setOn(true, animated: true)
            myData.set(allSwitch.isOn, forKey: "all")
            
            myData.set(sender.isOn, forKey: "push1")
            comment = String(myData.bool(forKey: "push1"))
            
        } else {
            
            self.allPushOff()
            
            myData.set(sender.isOn, forKey: "push1")
            comment = String(myData.bool(forKey: "push1"))
            
        }
        
        changePush()
        
    }
    
    @IBAction func followPush(_ sender: UISwitch) {
        
        myData.set(sender.isOn, forKey: "push2")
        
        if sender.isOn{
            
            allSwitch.setOn(true, animated: true)
            myData.set(allSwitch.isOn, forKey: "all")
            
            myData.set(sender.isOn, forKey: "push2")
            follow = String(myData.bool(forKey: "push2"))
            
        } else {
            
            self.allPushOff()
            
            myData.set(sender.isOn, forKey: "push2")
            follow = String(myData.bool(forKey: "push2"))
            
        }
        
        changePush()
        
    }
    
    @IBAction func newProductPush(_ sender: UISwitch) {
        
        myData.set(sender.isOn, forKey: "push3")
        
        if sender.isOn{
            
            allSwitch.setOn(true, animated: true)
            myData.set(allSwitch.isOn, forKey: "all")
            
            myData.set(sender.isOn, forKey: "push3")
            newProduct = String(myData.bool(forKey: "push3"))
            
        } else {
            
            self.allPushOff()
            
            myData.set(sender.isOn, forKey: "push3")
            newProduct = String(myData.bool(forKey: "push3"))
            
        }
        
        changePush()
        
    }
    
    @IBAction func messagePush(_ sender: UISwitch) {
        
        myData.set(sender.isOn, forKey: "push4")
        
        if sender.isOn{
            
            allSwitch.setOn(true, animated: true)
            myData.set(allSwitch.isOn, forKey: "all")
            
            myData.set(sender.isOn, forKey: "push4")
            message = String(myData.bool(forKey: "push4"))

        } else {
            
            self.allPushOff()
            
            myData.set(sender.isOn, forKey: "push4")
            message = String(myData.bool(forKey: "push4"))
            
        }
        
        changePush()
        
    }
    
    func changePush() {
        let paramter = ["push1":comment,
                        "push2":follow,
                        "push3":newProduct,
                        "push4":message,
                        "token":token]
        print("[ parameter ] : \(paramter)")
        
        Alamofire.request(domain + pushNoticeURL, method: .post, parameters: paramter, encoding: URLEncoding.default, headers: nil)
    }
    
    @IBAction func DoneBtn(_ sender: UIBarButtonItem) {
        
        self.tabBarController?.tabBar.isHidden = false
        
        print("[ push1 ] : \(comment)")
        print("[ push2 ] : \(follow)")
        print("[ push3 ] : \(newProduct)")
        print("[ push4 ] : \(message)")
        
        changePush()
        self.navigationController?.popViewController(animated: true)
        
    }

}
