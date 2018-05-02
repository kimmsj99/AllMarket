//
//  CategoryController.swift
//  AllMarket
//
//  Created by 김민주 on 2017. 8. 22..
//  Copyright © 2017년 MinJu. All rights reserved.
//

import UIKit

class CategoryController: UIViewController {
    
    let myData : UserDefaults = UserDefaults.standard

    @IBOutlet weak var guideView: UIView!
    
    @IBOutlet weak var sellBtn: UIButton!
    @IBOutlet weak var sellLabel: UILabel!
    @IBOutlet weak var cartImg: UIImageView!
    @IBOutlet weak var sellSet: UIView!
    
    @IBOutlet weak var buyBtn: UIButton!
    @IBOutlet weak var buyLabel: UILabel!
    @IBOutlet weak var coinImg: UIImageView!
    @IBOutlet weak var buySet: UIView!
    
    static var selectedItem = ""
    
    var languageTitle = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.isHidden = false
        
        var tmpView = UIView()
        
        if UIScreen.main.nativeBounds.height == 2436 {
            tmpView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 44.0 ))
            tmpView.backgroundColor = UIColor.init(hex: "051c30")
            self.view.addSubview(tmpView)
        } else {
            tmpView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 20.0 ))
            tmpView.backgroundColor = UIColor.init(hex: "051c30")
            self.view.addSubview( tmpView )
        }
        
        myData.removeObject(forKey: "keyword")
        myData.removeObject(forKey: "keywordURL")
        myData.removeObject(forKey: "searchRes")
        myData.removeObject(forKey: "filterRes")
        
        guideView.frame.origin.x = 0
        guideView.center.y = self.view.frame.height / 2
        
        sellBtn.center.x = self.view.frame.width / 2
        sellSet.center.x = self.view.frame.width / 2
        
        buyBtn.center.x = self.view.frame.width / 2
        buySet.center.x = self.view.frame.width / 2
        
        sellBtn.setImage(UIImage(named: "upNavyBack"), for: .normal)
        sellLabel.textColor = UIColor.init(hex: "ffffff")
        cartImg.image = UIImage(named: "whiteCart")

        buyBtn.setImage(UIImage(named: "downWhiteBack"), for: .normal)
        buyLabel.textColor = UIColor.init(hex: "051c30")
        coinImg.image = UIImage(named: "navyCoin")
        
        self.setNeedsStatusBarAppearanceUpdate()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        // 다른 뷰에선 네비게이션바 보이게
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        
        sellBtn.setImage(UIImage(named: "upNavyBack"), for: .normal)
        sellLabel.textColor = UIColor.init(hex: "ffffff")
        cartImg.image = UIImage(named: "whiteCart")

        buyBtn.setImage(UIImage(named: "downWhiteBack"), for: .normal)
        buyLabel.textColor = UIColor.init(hex: "051c30")
        coinImg.image = UIImage(named: "navyCoin")
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        myData.removeObject(forKey: "keyword")
        myData.removeObject(forKey: "keywordURL")
        myData.removeObject(forKey: "searchRes")
        myData.removeObject(forKey: "filterRes")
        
    }
    
    //팝니다 버튼을 눌렀을 때
    @IBAction func sellBtnAction(_ sender: UIButton) {
        
        languageTitle = "sell".localized + " > "

        myData.set("1", forKey: "bestLink")
        myData.set("1", forKey: "bestLinkChange")
        CategoryController.selectedItem = languageTitle
        
        let firstVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CategoryFirstController") as! CategoryFirstController
        self.navigationController?.pushViewController(firstVC, animated: true)
        
//        sellBtn.setImage(UIImage(named: "upWhiteBack"), for: .normal)
//        sellLabel.textColor = UIColor.init(hex: "051c30")
//        cartImg.image = UIImage(named: "navyCart")

//        let tmpArr: NSMutableArray = NSMutableArray()
//        tmpArr.add( "팝니다 > " )
//        print("[ tempArr ] : \(tmpArr)")
//        if( myData.object(forKey: "selectCell" ) != nil) {
//            myData.set(tmpArr, forKey: "selectCell" )
//            print("[ selectCell ] : \(myData.object(forKey: "selectCell")!)")
//        } else {
//            myData.set(tmpArr, forKey: "selectCell" )
//            print("[ selectCell ] : \(myData.object(forKey: "selectCell")!)")
//        }

    }
    
    //삽니다 버튼을 눌렀을 때
    @IBAction func buyBtnAction(_ sender: UIButton) {
        
        languageTitle = "buy".localized + " > "
        
        myData.set("2", forKey: "bestLink")
        myData.set("2", forKey: "bestLinkChange")
        CategoryController.selectedItem = languageTitle
        
        let firstVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CategoryFirstController") as! CategoryFirstController
        self.navigationController?.pushViewController(firstVC, animated: true)
        
//        buyBtn.setImage(UIImage(named: "downNavyBack"), for: .normal)
//        buyLabel.textColor = UIColor.init(hex: "ffffff")
//        coinImg.image = UIImage(named: "whiteCoin")
        
//        let tmpArr: NSMutableArray = NSMutableArray()
//        tmpArr.add( "삽니다 > " )
//        print("[ tempArr ] : \(tmpArr)")
//        if( myData.object(forKey: "selectCell" ) != nil) {
//            myData.set(tmpArr, forKey: "selectCell" )
//            print("[ selectCell ] : \(myData.object(forKey: "selectCell")!)")
//        } else {
//            myData.set(tmpArr, forKey: "selectCell" )
//            print("[ selectCell ] : \(myData.object(forKey: "selectCell")!)")
//        }
        
//        CategoryController.temp.append("삽니다 > ")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}
