//
//  CategorySecondController.swift
//  AllMarket
//
//  Created by 김민주 on 2017. 8. 22..
//  Copyright © 2017년 MinJu. All rights reserved.
//

import UIKit
import Alamofire

class CategorySecondController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    
    enum Mode {
        case none       //아무것도 없들 때
        case plain      //기본
        case search     //검색할 때
    }
    
    var mode : Mode = .plain
    
    @IBOutlet weak var secondTableView: UITableView!
    
    let myData : UserDefaults = UserDefaults.standard
    let language = UserDefaults.standard.object(forKey: "selectLanguageEng") as! String
    
    var resultSearchController: UISearchController!
    private var searchBar: UISearchBar!
    
    var searchClick = false
    
    var selectMC = UILabel()
    
    var selectedItemBefore = ""
    
    var filteredData = [Category]()
    
    let searchIcon = #imageLiteral(resourceName: "searchIcon")
    let resetIcon = #imageLiteral(resourceName: "resetIcon")
    
    @IBOutlet weak var heightInterval: NSLayoutConstraint!
    
    lazy var secondList : [Category] = {
        var datalist = [Category]()
        
        return datalist
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.parseCategory()
        
        let title : String = myData.string(forKey: "title")!
        navigationTitle(self, title)
        
//        searchBar = UISearchBar()
//        searchBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 77)
//        searchBar.barTintColor = UIColor.init(hex: "ECECEC")
//        self.view.addSubview(searchBar)
        
        //네비게이션 backButton 숨기기
        self.navigationItem.setHidesBackButton(true, animated:true)
        
        //제스처로 뒤로가기
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        self.createSearchBar()
        
        selectMC = UILabel(frame: CGRect(x: 21, y: 7, width: 340, height: 17))
        selectMC.text = selectedItemBefore + CategoryController.selectedItem
        selectMC.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightMedium)
        selectMC.textColor = UIColor.init(hex: "333333")
        self.view.addSubview(selectMC)
        
        self.secondTableView.tableFooterView = UIView(frame: CGRect.zero)
        self.secondTableView.tableFooterView?.isHidden = true
        self.secondTableView.backgroundColor = UIColor.init(hex: "ececec")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if let selectionIndexPath = self.secondTableView.indexPathForSelectedRow {
            self.secondTableView.deselectRow(at: selectionIndexPath, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
//        createSearchTF(target: self.view, search: resultSearchController)
//
//        for sView in resultSearchController.searchBar.subviews {
//            for ssView in sView.subviews {
//                if ssView.isKind(of: UITextField.self) {
//                    let searchTextField = ssView as! UITextField
//                    searchTextField.frame = CGRect(x: 19, y: 0, width: 308, height: 36)
//                    searchTextField.center.y = resultSearchController.searchBar.frame.height / 2
//
//                }
//                if ssView.isKind(of: UIButton.self) {
//                    let cancelButton = ssView as! UIButton
//                    let searchTFX = self.resultSearchController.searchBar.frame.width - 336
//                    cancelButton.frame.origin.x = self.resultSearchController.searchBar.frame.width - searchTFX
//                    cancelButton.center.y = resultSearchController.searchBar.frame.height / 2
//                    cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
//                    cancelButton.tintColor = UIColor.init(hex: "5a5a5a")
//                    break
//                }
//            }
//        }
        
        myData.removeObject(forKey: "Midx")
        myData.removeObject(forKey: "MTitle")
        
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
        
        let Bidx = myData.object(forKey: "Bidx") as! String
        
        let parameter = ["idx":Bidx]
        
        Alamofire.request(
            domain + getMCategoryURL + "/\(self.language)",
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
                            
                            self.secondList.append(categoryList)
                            self.filteredData.append(categoryList)
                            
                        }
                        self.secondTableView.reloadData()
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
            return self.secondList.count
        case .search:
            return self.filteredData.count
        }
    }
    
    //셀의 내용을 리턴하는 함수
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var row: Category
        
        let cell = secondTableView.dequeueReusableCell(withIdentifier: "cell") as! CategoryCell
        
        switch self.mode {
        case .none:
            return UITableViewCell()
        case .plain:
            row = self.secondList[indexPath.row]
            
            if indexPath.row == 0 {
                cell.categoryLabel.font = UIFont.systemFont(ofSize: 13.0, weight: UIFontWeightBold)
                cell.categoryLabel.font = UIFont.systemFont(ofSize: 13.0, weight: UIFontWeightMedium)
                cell.categoryLabel.textColor = UIColor.init(hex: "333333")
            } else {
                cell.categoryLabel.font = UIFont.systemFont(ofSize: 13.0)
                cell.categoryLabel.textColor = UIColor.init(hex: "5a5a5a")
            }
            
            if searchClick == true {
                heightInterval.constant = 95
                resultSearchController.searchBar.isHidden = true
                self.view.willRemoveSubview(resultSearchController.searchBar)
                createSearchBar()
                selectMC.isHidden = false
                self.view.addSubview(selectMC)
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
            row = self.secondList[indexPath.row]
            
            if row.idx == "0" {
                myData.set("0", forKey: "Midx")
                if let naviVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WKItemResultController") as? UINavigationController,
                let wkItemResultController = naviVC.viewControllers.first as? WKItemResultController {
                    wkItemResultController.search = { [weak self] in
                        self?.resultSearchController.searchBar.isUserInteractionEnabled = true
                        self?.resultSearchController.isActive = true
                        self?.resultSearchController.searchBar.becomeFirstResponder()
                    }
                    
                    present(naviVC, animated: true, completion: nil)
                }
                
            } else {
                
                let MC = row.list! + " > "
                
                myData.set(row.list!, forKey: "title")
                myData.set(row.list!, forKey: "MTitle")
                myData.set(row.idx!, forKey: "Midx")
                
                if let thirdVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ThirdVC") as? CategoryThirdController {
                    
                    thirdVC.selectedItemBefore = self.selectMC.text!
                    CategoryController.selectedItem = MC
                    
                    self.navigationController?.pushViewController(thirdVC, animated: true)
                    
                }
            }
        case .search:
            row = self.filteredData[indexPath.row]
            
            resultSearchController.searchBar.text = row.list
            
            self.secondTableView.reloadData()
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
        
        selectMC.isHidden = true
        print("검색 단어 : \(resultSearchController.searchBar.text!)")
        
        if !resultSearchController.searchBar.text!.isEmpty {
            mode = .search
        } else if mode != .plain && resultSearchController.searchBar.text!.isEmpty {
            mode = .none
            self.secondTableView.reloadData()
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
                                    
                                    self.secondTableView.reloadData()
                                    
                                } catch {
                                    self.mode = .none
                                    self.secondTableView.reloadData()
                                    print("search error : \(error)")
                                }
                                
                          })
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        self.mode = .none
        self.secondTableView.reloadData()
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
        self.secondTableView.reloadData()
    }
    
    func clearClicked(_ sender: UIButton) {
        self.resultSearchController.searchBar.text! = ""
    }
    
}
