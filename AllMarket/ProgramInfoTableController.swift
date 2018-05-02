//
//  ProgramInfoTableController.swift
//  AllMarket
//
//  Created by 김민주 on 2017. 9. 25..
//  Copyright © 2017년 MinJu. All rights reserved.
//

import UIKit

class ProgramInfoTableController: UITableViewController {
    
    @IBOutlet weak var currentVer: UILabel!
    @IBOutlet weak var newVer: UILabel!
    @IBOutlet weak var guideView: UIView!
    @IBOutlet weak var amLogo: UIImageView!
    
    let appId = "1329454669"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        amLogo.frame = CGRect(x: 0, y: 0, width: 190, height: 126)
        amLogo.center = CGPoint(x: self.view.frame.width / 2, y: self.guideView.frame.height / 2 - 20)
        
        self.tabBarController?.tabBar.isHidden = true
        
        self.view.backgroundColor = UIColor.init(hex: "051c30")
        
        guideView.backgroundColor = UIColor.init(hex: "051c30")
        
        navigationTitle(self, "programInfoTitle".localized);
        
        navigationItem.leftBarButtonItems = CustomBackButton.createWithImage(view: self.view, image: #imageLiteral(resourceName: "backBtn"), color: .white, target: self, action: #selector(DoneBtn(_:)))
        
        let infoDic = Bundle.main.infoDictionary!
        let appVersion = infoDic["CFBundleShortVersionString"] as! String
        
        newVersion()
        
        currentVer.text = appVersion
        newVer.text = appVersion
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.tableFooterView?.isHidden = true
        self.tableView.backgroundColor = UIColor.white
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if let selectionIndexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: selectionIndexPath, animated: true)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            break
        case 1:
            break
        case 2:
            print("이용 약관")
            
            let AmTou = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AmTou") as!  AmTouController
            
            self.navigationController?.pushViewController(AmTou, animated: true)
            
            break
        default:
            return
        }
        
    }
    
    func DoneBtn(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        self.tabBarController?.tabBar.isHidden = false
//        self.dismiss(animated: true, completion: nil)
    }
    
}

extension ProgramInfoTableController {
    
    func newVersion() {
        let infoDic = Bundle.main.infoDictionary
        let appID : String = infoDic!["CFBundleIdentifier"] as! String
        
        let url : URL = URL(string: "http://itunes.apple.com/lookup?bundleId=\(appID)")!
        let data = try! Data(contentsOf: url)
        
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions())
            let dic = json as! NSDictionary
            
            if dic.object(forKey: "resultCount") as! Int != 0 {
                let result = (dic.object(forKey: "results") as! NSArray)[0]
                let str_appV = (result as AnyObject).object(forKey: "version") as! String
                let str_currentV = infoDic!["CFBundleShortVersionString"] as! String
                print("appVersion = \(str_appV), currentVersion = \(str_currentV)")
                newVer.text = str_appV
                currentVer.text = str_currentV
            }else {
                print("결과값이 없음")
            }
        } catch {
            print(error)
        }
    }
    
//    func run() {
//        guard let url = URL(string: "https://itunes.apple.com/kr/lookup?id=\(appId)") else { return }
//        let request = URLRequest(url: url)
//        let session = URLSession(configuration: .default)
//
//        let task = session.dataTask(with: request, completionHandler: {
//            (data, _, _) in
//            guard let d = data else { return }
//            do {
//                guard let results = try JSONSerialization.jsonObject(with: d, options: .allowFragments) as? NSDictionary else { return }
//                guard let resultsArray = results.value(forKey: "results") as? NSArray else { return }
//                guard let storeVersion = (resultsArray[0] as? NSDictionary)?.value(forKey: "version") as? String else { return }
//                guard let installVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else { return }
//                guard installVersion.compare(storeVersion) == .orderedAscending else { return }
//
//                print(installVersion)
//            } catch {
//                print("Serialization error")
//            }
//        })
//        task.resume()
//    }
    
//    func needUpdate() -> NSDictionary {
//
//        let ret = NSMutableDictionary()
//
//        //
//        let infoDic = Bundle.main.infoDictionary
//        let appID = infoDic!["CFBundleIdentifier"] as! String
//        let jsonData = getJSON("http://itunes.apple.com/lookup?bundleId=\(appID)")
//        let lookup = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as! NSDictionary
//
//        //
//        let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
//        ret.setValue(appVersion, forKey: "appVersion")
//        ret.setValue(false, forKey: "needUpdate")
//
//        //
//        if ( lookup!["resultCount"]?.integerValue == 1 ) {
//            let resultsArray = lookup!["results"] as! NSArray // MDLMaterialProperty to Array
//            let resultsDic = resultsArray[0] as! NSDictionary
//            let storeVersion = resultsDic["version"] as! String
//            if (storeVersion as NSString).compare(appVersion, options: NSStringCompareOptions.NumericSearch) == NSComparisonResult.OrderedDescending {
//                ret.setValue(true, forKey: "needUpdate")
//            }
//            ret.setValue(storeVersion, forKey: "storeVersion")
//        }
//
//        return ret
//    }
}
