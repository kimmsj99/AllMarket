//
//  CategoryNavigation.swift
//  AllMarket
//
//  Created by 김민주 on 2017. 8. 21..
//  Copyright © 2017년 MinJu. All rights reserved.
//

import UIKit
//import Material

class NavigationController: UINavigationController, UIGestureRecognizerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.barTintColor = UIColor.init(hex: "051c30")
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        navigationBar.isTranslucent = false
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
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
        
//        navigationBar.backItem?.backButton.setImage(UIImage(named: "backBtn"), for: .normal)
        
        self.setNeedsStatusBarAppearanceUpdate()
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}
