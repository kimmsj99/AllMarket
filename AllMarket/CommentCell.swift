//
//  CommentTableViewCell.swift
//  AllMarket
//
//  Created by MAC on 2017. 8. 30..
//  Copyright © 2017년 MinJu. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {
    
    var commentList: Comment? {
        didSet {
            
            if let content = commentList?.comment_content{
                self.contentLabel.text = content
            }
            
            if let date = commentList?.comment_date {
                self.dateLabel.text = date
            }
            
            if let item = commentList?.item_title {
                self.goodsLabel.text = item
            }
        }
    }
    
    @IBOutlet weak var commentImg: UIImageView!
    
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var goodsLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
}
