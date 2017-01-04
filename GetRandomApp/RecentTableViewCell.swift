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
    
    
    var indexPath = IndexPath()
    var storeURL = NSURL()
    
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
    
    @IBAction func share() {
        
        // 共有する項目
        let adText = NSLocalizedString("found", comment: "")
        let shareText = appTitleLabel.text!
        let shareWebsite = storeURL
        let shareImage = IconImageView.image!
        
        let activityItems = [adText, shareText, shareWebsite, shareImage] as [Any]
        
        // 初期化処理
        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        // 使用しないアクティビティタイプ
        let excludedActivityTypes = [
            UIActivityType.print,
            UIActivityType.assignToContact,
            UIActivityType.saveToCameraRoll,
            UIActivityType.addToReadingList,
            UIActivityType.airDrop,
            UIActivityType.copyToPasteboard
        ]
        
        activityVC.excludedActivityTypes = excludedActivityTypes
        
        // UIActivityViewControllerを表示
        self.window?.rootViewController?.present(activityVC, animated: true, completion: nil)
    }
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
