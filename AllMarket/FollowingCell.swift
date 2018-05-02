//
//  FollowingCell.swift
//  AllMarket
//
//  Created by MAC on 2017. 9. 6..
//  Copyright © 2017년 MinJu. All rights reserved.
//

import UIKit

class FollowingCell: UITableViewCell {
    
    var followingList: FollowingUser? {
        didSet {
            
            if let subPath = followingList?.img {
                if subPath == "" {
                    self.profileImg.image = UIImage(named: "p_profile")
                } else {
                    let imagePath = domain + subPath
                    print(imagePath)
                    
                    let imageData = try? Data(contentsOf : URL(string: imagePath)!)
                    
                    self.profileImg.image = UIImage(data: imageData!)
                    self.profileImg.layer.cornerRadius = self.profileImg.bounds.width / 2.0
                    self.profileImg.clipsToBounds = true
                }
            }
            
            if let followingUserName = followingList?.name{
                self.userName.text = followingUserName
            }
            
            if let followingProductCnt = followingList?.cnt {
                self.productCnt = followingProductCnt
            }
            
            if let followingFollwerCnt = followingList?.my_follower {
                self.followerCnt = followingFollwerCnt
            }
        }
    }

    @IBOutlet weak var profileImg: UIImageView!
    
    @IBOutlet weak var userName: UILabel!

    var productCnt: String!
    
    var followerCnt: String!
    
    @IBOutlet weak var userCnt: UILabel!
    
    @IBOutlet weak var followBtn: UIButton!
    
}
