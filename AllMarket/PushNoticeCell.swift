//
//  PushNoticeTableViewCell.swift
//  AllMarket
//
//  Created by MAC on 2017. 8. 30..
//  Copyright © 2017년 MinJu. All rights reserved.
//

import UIKit

class PushNoticeCell: UITableViewCell {
    
    @IBOutlet weak var pushLabel: UILabel!
    
    @IBOutlet weak var pushSwitch: UISwitch!

    @IBAction func pushSwitch(_ sender: UISwitch) {
        
        if pushSwitch.isOn {
            print("@@@@@ \(pushLabel.text!) 설정 @@@@@")
        } else {
            print("@@@@@ \(pushLabel.text!) 해제 @@@@@")
        }
        
    }
}
