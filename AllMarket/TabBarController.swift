//
//  TabBarController.swift
//  AllMarket
//
//  Created by 김민주 on 2017. 8. 24..
//  Copyright © 2017년 MinJu. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    let myData = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()

        UITabBar.appearance().tintColor = UIColor.init(hex: "051c30")
        
    }
    
    override func viewWillLayoutSubviews() {
        var tabFrame = self.tabBar.frame
        // - 40 is editable , the default value is 49 px, below lowers the tabbar and above increases the tab bar size
        if UIScreen.main.nativeBounds.height != 2436 {
            tabFrame.size.height = 46
            tabFrame.origin.y = self.view.frame.size.height - 46
            self.tabBar.frame = tabFrame
        }
        
    }
    
}
