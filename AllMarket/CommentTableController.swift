//
//  CommentTableController.swift
//  AllMarket
//
//  Created by 김민주 on 2017. 9. 19..
//  Copyright © 2017년 MinJu. All rights reserved.
//

import UIKit
import Alamofire

class Comment {   
    var comment_content: String?
    var comment_date: String?
    var item_title: String?
    var url: String?
}

class CommentTableController: UITableViewController {
    
    let user_idx = UserDefaults.standard.object(forKey: "user_idx") as! String
    let language = UserDefaults.standard.object(forKey: "selectLanguageEng") as! String

    @IBOutlet weak var backBtn: UIBarButtonItem!
    
    var commentList = [Comment]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationTitle(self, "commentTitle".localized)
        
        backBtn.image = UIImage(named:"backBtn")?.withRenderingMode(.alwaysOriginal)
        
        self.addRefreshControl()
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.tableFooterView?.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.tabBarController?.tabBar.isHidden = true
        
        if let selectionIndexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: selectionIndexPath, animated: true)
        }
        
        requestCommentList()
    }
    
    func requestCommentList(){
        
        commentList = []
        
        if (UserDefaults.standard.object(forKey: "idx") == nil){
            let parameter = ["user_idx":user_idx]
            print("parameter : \(parameter)")
            
            Alamofire.request(domain + commentURL + "/\(self.language)", method: .post, parameters: parameter, encoding: URLEncoding.default, headers: nil).response(completionHandler: { (response) in
                self.parseComment(JSONData: response.data!)
            })
        }
        
    }
    
    func parseComment(JSONData: Data) {
        do {
            let readableJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! NSArray
            print("[ Comment JSON ] : \(readableJSON)")
            
            print("[ Comment Count ] : \(readableJSON.count)")
            
            for i in 0..<readableJSON.count {
                if let commentList = readableJSON[i] as? [String:AnyObject] {

                    let commentListStore = Comment()
                    commentListStore.comment_content = commentList["comment_content"] as? String
                    commentListStore.comment_date = commentList["comment_date"] as? String
                    commentListStore.item_title = commentList["item_title"] as? String
                    commentListStore.url = commentList["url"] as? String

                    self.commentList.append(commentListStore)
                }
            }
            self.tableView.reloadData()
            
        } catch {
            print("[ Comment Error ] : \(error)")
        }
    }
    
    func addRefreshControl(){
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshWebView(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    func refreshWebView(_ sender: UIRefreshControl) {
        tableView.reloadData()
        sender.endRefreshing()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.commentList.count
//        return contentArr.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! CommentCell
        
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        
        cell.commentList = self.commentList[indexPath.row]
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(profileTapped(tapGestureRecognizer:)))
        cell.isUserInteractionEnabled = true
        cell.addGestureRecognizer(tap)
        cell.tag = indexPath.item
        
        return cell
    }
    
    var selectedItemURL = ""
    
    func profileTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        let view = tapGestureRecognizer.view
        let index = view?.tag
        
        selectedItemURL = commentList[index!].url!
        
        print("selectedItemURL : \(selectedItemURL)")
        
        UserDefaults.standard.set(selectedItemURL, forKey: "ItemInfoURL")
        
//        changeView(target: self, identifier: "ItemInfo")
        let ItemInfo = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ItemInfo") as!  WKItemInfoController
        
        self.navigationController?.pushViewController(ItemInfo, animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 91.0
    }
    
    @IBAction func DoneBtn(_ sender: UIBarButtonItem) {
        
        self.navigationController?.popViewController(animated: true)
        
    }
}
