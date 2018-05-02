//
//  CategoryNavigationController.swift
//  AllMarket
//
//  Created by 김민주 on 2017. 11. 9..
//  Copyright © 2017년 MinJu. All rights reserved.
//

import UIKit

class CategoryNavigationController: UINavigationController, UIGestureRecognizerDelegate {
    
    let myData = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.barTintColor = UIColor.init(hex: "051c30")
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        navigationBar.isTranslucent = false
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        
        if myData.object(forKey: "menu") as? String == "true" {
            let categoryFirstController = storyboard.instantiateViewController(withIdentifier: "CategoryFirstController")
            myData.set("1", forKey: "bestLink")
            myData.set("1", forKey: "bestLinkChange")
            let langTitle = "sell".localized + " > "
            CategoryController.selectedItem = langTitle
            self.setViewControllers([categoryFirstController], animated: true)
            
        } else {
            let categoryController = storyboard.instantiateViewController(withIdentifier: "CategoryController")
            self.setViewControllers([categoryController], animated: true)
            
        }
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}
