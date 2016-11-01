//
//  RecentTableViewCell.swift
//  GetRandomApp
//
//  Created by Family Account on 2016/10/29.
//  Copyright © 2016年 Family Account. All rights reserved.
//

import UIKit

class RecentTableViewCell: UITableViewCell {

    @IBOutlet var IconImageView: UIImageView!
    @IBOutlet var appTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        appTitleLabel.adjustsFontSizeToFitWidth = true
        appTitleLabel.numberOfLines = 0
        IconImageView.layer.borderColor = UIColor.lightGray.cgColor
        IconImageView.layer.borderWidth = 0.5
        IconImageView.layer.cornerRadius = 20
        IconImageView.layer.masksToBounds = true
        
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
