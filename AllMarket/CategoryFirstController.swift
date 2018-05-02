//
//  CategoryFirstController.swift
//  AllMarket
//
//  Created by 김민주 on 2017. 8. 22..
//  Copyright © 2017년 MinJu. All rights reserved.
//

import UIKit
import Alamofire

var items = [String]()

class CategoryFirstController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate, UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating {
    
    enum Mode {
        case none       //아무것도 없들 때
        case plain      //기본
        case search     //검색할 때
    }
    
    var mode : Mode = .plain

    @IBOutlet weak var firstTableView: UITableView!
    @IBOutlet weak var backBtn: UIBarButtonItem!
    
    let myData = UserDefaults.standard
    let language = UserDefaults.standard.object(forKey: "selectLanguageEng") as! String
    
    var resultSearchController: UISearchController!
    private var searchBar: UISearchBar!
    
    var searchClick = false
    
    var selectBC = UILabel()
    
    var filteredData = [Category]()
    @IBOutlet weak var heightInterval: NSLayoutConstraint!
    
    let searchIcon = #imageLiteral(resourceName: "searchIcon")
    let resetIcon = #imageLiteral(resourceName: "resetIcon")
    
    lazy var firstList : [Category] = {
        var datalist = [Category]()
        
        return datalist
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.isHidden = false
        
        self.parseCategory()
        
//        if L102Language.currentAppleLanguage() == "ko" {
//            navigationTitle(self, "카테고리")
//        } else if L102Language.currentAppleLanguage() == "en" {
//            navigationTitle(self, "Category ")
//        } else if L102Language.currentAppleLanguage() == "vi" {
//            navigationTitle(self, "Thể loại")
//        }
        
        navigationTitle(self, "categoryTitle".localized)
        
        //네비게이션 backButton 숨기기
        self.navigationItem.setHidesBackButton(true, animated:true)
        
//        //제스처로 뒤로가기
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
//        searchBar = UISearchBar()
//        searchBar.delegate = self
//        searchBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 77)
//        searchBar.barTintColor = UIColor.init(hex: "ECECEC")
//        self.view.addSubview(searchBar)
        
        self.createSearchBar()
        
        selectBC = UILabel(frame: CGRect(x: 21, y: 7, width: 340, height: 17))
        selectBC.text = CategoryController.selectedItem
        selectBC.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightMedium)
        selectBC.textColor = UIColor.init(hex: "333333")
        self.view.addSubview(selectBC)
        
        self.firstTableView.tableFooterView = UIView(frame: CGRect.zero)
        self.firstTableView.tableFooterView?.isHidden = true
        self.firstTableView.backgroundColor = UIColor.init(hex: "ececec")
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if let selectionIndexPath = self.firstTableView.indexPathForSelectedRow {
            self.firstTableView.deselectRow(at: selectionIndexPath, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
//        createSearchTF(target: self.view, search: resultSearchController)
//        createSearchTF(target: self.view, search: resultSearchController.searchBar)
//        createSearchTF(target: self.view, search: searchBar)
//        self.createSearchBar()
        
        myData.removeObject(forKey: "Bidx")
        
    }
    
    func parseCategory(){
        Alamofire.request(domain + getBCategoryURL + "/\(self.language)").response(completionHandler: { (response) in
            self.filteredData.removeAll()
            do {
                let readableJSON = try JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) as! NSArray

                for array in readableJSON {
                    let row = array as! NSDictionary

                    let categoryList = Category()

                    categoryList.list = row[self.language] as? String
                    categoryList.idx = row["idx"] as? String
                    
                    let list = row[self.language] as? String

                    self.firstList.append(categoryList)
                    self.filteredData.append(categoryList)
                }
                self.firstTableView.reloadData()
            } catch {

                print("Category Error : \(error)")
                basicAlert(target: self, title: "파싱 실패", message: "다시 시도해주세요")
            }
        })
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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch mode {
        case .none:
            return 0
        case .plain:
            return self.firstList.count
        case .search:
            return self.filteredData.count
        }
    }
    
    //셀의 내용을 리턴하는 함수
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var row: Category
        
        let cell = firstTableView.dequeueReusableCell(withIdentifier: "cell") as! CategoryCell
        
        switch self.mode {
        case .none:
            return UITableViewCell()
        case .plain:
            row = self.firstList[indexPath.row]
            
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
                selectBC.isHidden = false
                self.view.addSubview(selectBC)
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
            row = self.firstList[indexPath.row]
            
            if row.idx == "0" {
                myData.set("0", forKey: "BTitle")
                myData.set("0", forKey: "Bidx")
                
                if let naviVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WKItemResultController") as? UINavigationController,
                    let wkItemResultController = naviVC.viewControllers.first as? WKItemResultController {
                    wkItemResultController.search = { [weak self] in
                        self?.resultSearchController.searchBar.isUserInteractionEnabled = true
                        self?.resultSearchController.isActive = true
                        self?.resultSearchController.searchBar.becomeFirstResponder()
                    }
                    
                    present(naviVC, animated: true, completion: nil)
                }
//                changeView(target: self, identifier: "ItemResult")
            } else {
                let BC = row.list! + " > "
                
                myData.set(row.list!, forKey: "BTitle")
                myData.set(row.list!, forKey: "title")
                myData.set(row.idx!, forKey: "Bidx")
                
                if let secondVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SecondVC") as?  CategorySecondController {
                    
                    secondVC.selectedItemBefore = self.selectBC.text!
                    CategoryController.selectedItem = BC
                    
                    self.navigationController?.pushViewController(secondVC, animated: true)
                }
            }
            
        case .search:
            row = self.filteredData[indexPath.row]
            resultSearchController.searchBar.text = row.list
            
            if resultSearchController.searchBar.text == row.list {
                self.firstTableView.reloadData()
            }
            
            self.firstTableView.reloadData()
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont.systemFont(ofSize: 14.0, weight: UIFontWeightMedium)
        header.textLabel?.textColor = UIColor.init(hex: "333333")
        switch mode {
        case .none:
            header.backgroundColor = UIColor(hex: "ffffff")
        default:
            header.backgroundColor = UIColor.init(hex: "ececec")
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
        
        if !resultSearchController.searchBar.text!.isEmpty {
            mode = .search
        } else if mode != .plain && resultSearchController.searchBar.text!.isEmpty {
            mode = .none
            self.firstTableView.reloadData()
            return
        }
        
        let parameter = ["search": resultSearchController.searchBar.text!]
        
        Alamofire.request(domain + searchURL,
                          method: .post,
                          parameters: parameter,
                          encoding: URLEncoding.default,
                          headers: nil).response(completionHandler: { (response) in
            
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
                                
                                self.firstTableView.reloadData()
                                
                            } catch {
                                self.mode = .none
                                self.firstTableView.reloadData()
                                print("search error : \(error)")
                            }
                            
                          })
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        self.mode = .none
        self.firstTableView.reloadData()
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchbar: UISearchBar){
        resultSearchController.searchBar.resignFirstResponder()
        
        if self.resultSearchController.searchBar.text! == "" {
            basicAlert(target: self, title: nil, message: "inputSearchText".localized)
        }
        
        UserDefaults.standard.set(resultSearchController.searchBar.text!, forKey: "keyword")
        changeView(target: self, identifier: "ItemSearch")
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.mode = .plain
        self.firstTableView.reloadData()
    }
    
}
