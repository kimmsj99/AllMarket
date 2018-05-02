//
//  CategoryThirdController.swift
//  AllMarket
//
//  Created by 김민주 on 2017. 8. 23..
//  Copyright © 2017년 MinJu. All rights reserved.
//

import UIKit
import Alamofire

class CategoryThirdController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIGestureRecognizerDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    
    enum Mode {
        case none       //아무것도 없들 때
        case plain      //기본
        case search     //검색할 때
    }
    
    var mode: Mode = .plain
    
    @IBOutlet weak var thirdTableView: UITableView!
    
    let myData = UserDefaults.standard
    let language = UserDefaults.standard.object(forKey: "selectLanguageEng") as! String
    
    var resultSearchController: UISearchController!
    private var searchBar: UISearchBar!
    
    var searchClick = false
    
    var selectSC = UILabel()
    
    var selectedItemBefore = ""
    
    var filteredData = [Category]()
    
    let searchIcon = #imageLiteral(resourceName: "searchIcon")
    let resetIcon = #imageLiteral(resourceName: "resetIcon")
    
    @IBOutlet weak var heightInterval: NSLayoutConstraint!
    
    lazy var thirdList : [Category] = {
        var datalist = [Category]()
        
        return datalist
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.parseCategory()
        
        let title : String = myData.string(forKey: "title")!
        navigationTitle(self, title)
        
//        searchBar = UISearchBar()
//        searchBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 77)
//        searchBar.barTintColor = UIColor.init(hex: "ECECEC")
//        self.view.addSubview(searchBar)
        
        self.createSearchBar()
        
        selectSC = UILabel(frame: CGRect(x: 21, y: 7, width: 340, height: 17))
        selectSC.text = selectedItemBefore + CategoryController.selectedItem
        selectSC.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightMedium)
        selectSC.textColor = UIColor.init(hex: "333333")
        self.view.addSubview(selectSC)
        
        //네비게이션 backButton 숨기기
        self.navigationItem.setHidesBackButton(true, animated:true)
        
        //제스처로 뒤로가기
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        self.thirdTableView.tableFooterView = UIView(frame: CGRect.zero)
        self.thirdTableView.tableFooterView?.isHidden = true
        self.thirdTableView.backgroundColor = UIColor.init(hex: "ececec")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if let selectionIndexPath = self.thirdTableView.indexPathForSelectedRow {
            self.thirdTableView.deselectRow(at: selectionIndexPath, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
//        createSearchTF(target: self.view, search: resultSearchController)
        
        myData.removeObject(forKey: "Sidx")
        
    }
    
    func createSearchBar() {
        
        resultSearchController = UISearchController(searchResultsController: nil)
        
        resultSearchController.searchResultsUpdater = self
        
        resultSearchController.searchBar.delegate = self
        
        resultSearchController.hidesNavigationBarDuringPresentation = false
        
        resultSearchController.dimsBackgroundDuringPresentation = false
        
        resultSearchController.searchBar.searchBarStyle = UISearchBarStyle.prominent
        
        resultSearchController.searchBar.setImage(searchIcon, for: .search, state: .normal)
        
        resultSearchController.searchBar.setImage(resetIcon, for: .clear, state: .normal)
        
        resultSearchController.searchBar.sizeToFit()
        
        resultSearchController.searchBar.barTintColor = UIColor.init(hex: "ECECEC")
        resultSearchController.searchBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 95)
        resultSearchController.searchBar.placeholder = "searchPlacholder".localized
        
        self.view.addSubview(resultSearchController.searchBar)
    }
    
    func parseCategory(){
        
        let Midx = myData.object(forKey: "Midx") as! String
        
        let parameter = ["idx":Midx]
        
        Alamofire.request(
            domain + getSCategoryURL + "/\(self.language)",
            method: .post,
            parameters: parameter,
            encoding: URLEncoding.default,
            headers: nil).response(
                completionHandler: { (response) in
                    do{
                        let readableJSON = try JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) as! NSArray
                        print("JSON : \(readableJSON)")
                        
                        for array in readableJSON {
                            
                            let row = array as! NSDictionary
                            
                            let categoryList = Category()
                            
                            categoryList.list = row[self.language] as? String
                            categoryList.idx = row["idx"] as? String!
                            
                            self.thirdList.append(categoryList)
                            self.filteredData.append(categoryList)
                            
                        }
                        self.thirdTableView.reloadData()
                    }catch{
                        print(" error \(error)")
                        basicAlert(target: self, title: "파싱 실패", message: "다시 시도해주세요")
                    }
            })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch mode {
        case .none:
            return 0
        case .plain:
            return self.thirdList.count
        case .search:
            return self.filteredData.count
        }
    }
    
    //셀의 내용을 리턴하는 함수
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var row: Category
        
        let cell = thirdTableView.dequeueReusableCell(withIdentifier: "cell") as! CategoryCell
        
        switch self.mode {
        case .none:
            return UITableViewCell()
        case .plain:
            row = self.thirdList[indexPath.row]
            
            if indexPath.row == 0 {
                cell.categoryLabel.font = UIFont.systemFont(ofSize: 13.0, weight: UIFontWeightBold)
                cell.categoryLabel.font = UIFont.systemFont(ofSize: 13.0, weight: UIFontWeightMedium)
                cell.categoryLabel.textColor = UIColor.init(hex: "333333")
            }
            else {
                cell.categoryLabel.font = UIFont.systemFont(ofSize: 13.0)
                cell.categoryLabel.textColor = UIColor.init(hex: "5a5a5a")
            }
            
            if searchClick == true {
                heightInterval.constant = 95
                resultSearchController.searchBar.isHidden = true
                self.view.willRemoveSubview(resultSearchController.searchBar)
                createSearchBar()
                selectSC.isHidden = false
                self.view.addSubview(selectSC)
                searchClick = false
            }
            
        case .search:
            row = self.filteredData[indexPath.row]
            
            cell.categoryLabel.font = UIFont.systemFont(ofSize: 13.0)
            cell.categoryLabel.textColor = UIColor.init(hex: "5a5a5a")
        }
        
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        
        cell.categoryLabel.text = row.list
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var row: Category
        
        switch mode {
        case .none:
            return
        case .plain:
            row = self.thirdList[indexPath.row]
            
            if row.idx == "0" {
                myData.set("0", forKey: "Sidx")
                if let naviVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WKItemResultController") as? UINavigationController,
                    let wkItemResultController = naviVC.viewControllers.first as? WKItemResultController {
                    wkItemResultController.search = { [weak self] in
                        self?.resultSearchController.searchBar.isUserInteractionEnabled = true
                        self?.resultSearchController.isActive = true
                        self?.resultSearchController.searchBar.becomeFirstResponder()
                    }
                    
                    present(naviVC, animated: true, completion: nil)
                }
                
            }
            
            myData.set(row.list!, forKey: "title")
            myData.set(row.idx!, forKey: "Sidx")
            
            guard let user_idx = UserDefaults.standard.object(forKey: "user_idx") as? String else {
                return
            }
            
            let parameter = ["user_idx":user_idx,
                             "category_idx":row.idx!]
            print(parameter)
            
            Alamofire.request(
                domain + selectURL,
                method: .post,
                parameters: parameter,
                encoding: URLEncoding.default,
                headers: nil)
            
            self.performSegue(withIdentifier: "sgGoResult", sender: self)
        case .search:
            row = self.filteredData[indexPath.row]
            
            resultSearchController.searchBar.text = row.list
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        searchClick = true
        if self.view.frame.height == 736 - 64 {
            heightInterval.constant = 44
        } else {
            heightInterval.constant = 54
        }
        
        print("검색 단어 : \(resultSearchController.searchBar.text!)")
        
        if !resultSearchController.searchBar.text!.isEmpty {
            mode = .search
        } else if mode != .plain && resultSearchController.searchBar.text!.isEmpty && resultSearchController.searchBar.text! == "" {
            mode = .none
            return
        }
        
        let parameter = ["search": resultSearchController.searchBar.text!]
        
        Alamofire.request(domain + searchURL,
                          method: .post,
                          parameters: parameter,
                          encoding: URLEncoding.default,
                          headers: nil).response(
                            completionHandler: { (response) in
                            
                                do {
                                    self.filteredData.removeAll()
                                    let readableJSON = try JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) as! NSArray
                                    
                                    print("SEARCH JSON : \(readableJSON)")
                                    
                                    for idx in 0..<readableJSON.count {
                                        let row = readableJSON[idx] as! NSDictionary
                                        
                                        let word = row["result"] as! String
                                        print("word : \(word)")
                                        
                                        let resultCategory = Category()
                                        resultCategory.idx = String(idx)
                                        resultCategory.list = word
                                        self.filteredData.append(resultCategory)
                                        
                                    }
                                    
                                    self.thirdTableView.reloadData()
                                    
                                } catch {
                                    print("search error : \(error)")
                                }
                                
                          })
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        self.mode = .none
        self.thirdTableView.reloadData()
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchbar: UISearchBar){
        resultSearchController.searchBar.resignFirstResponder()
        
        if self.resultSearchController.searchBar.text! == "" {
            basicAlert(target: self, title: nil, message: "inputSearchText".localized)
        }
        
        UserDefaults.standard.set(self.resultSearchController.searchBar.text!, forKey: "keyword")
        changeView(target: self, identifier: "ItemSearch")
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.mode = .plain
        self.thirdTableView.reloadData()
    }
    
}
