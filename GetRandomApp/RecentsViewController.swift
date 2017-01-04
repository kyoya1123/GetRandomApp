
//
//  RecentsViewController.swift
//  GetRandomApp
//
//  Created by Family Account on 2016/10/29.
//  Copyright © 2016年 Family Account. All rights reserved.
//

import UIKit

class RecentsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet var table: UITableView!
    let label = UILabel()
    
    var titlesArray:[String]!
    var reversedTitlesArray: [String]!
    var imagesArray:[Data]!
    var reversedImagesArray: [Data] = []
    var URLsArray: [String]!
    var reversedURLsArray: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = NSLocalizedString("title2", comment: "")
        
        table.register(UINib(nibName: "RecentTableViewCell", bundle: nil), forCellReuseIdentifier:
            "Cell")
        table.delegate = self
        table.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if save.object(forKey: "titles") != nil {
            
            //データ読み込み
            table.backgroundColor = UIColor.white
            label.text = ""
            URLsArray = save.object(forKey: "URLs") as! [String]
            reversedURLsArray = URLsArray.reversed()
            titlesArray = save.object(forKey: "titles") as! [String]
            reversedTitlesArray =  titlesArray.reversed()
            imagesArray = save.object(forKey: "images") as! [Data]
            reversedImagesArray = imagesArray.reversed()
        }else if save.object(forKey: "titles") == nil{
            
            //データがない時の背景
            label.frame = CGRect(x: 83, y: 265, width: 155, height: 39)
            label.textAlignment = NSTextAlignment.center
            label.font = UIFont(name: "System", size: 20)
            label.text = NSLocalizedString("record", comment: "")
            label.textColor = UIColor.lightGray
            table.backgroundColor = UIColor(red:0.87, green:0.87, blue:0.87, alpha:0.5)
            table.backgroundView = label
            
        }
        self.table.tableFooterView = UIView()
        table.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reversedImagesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RecentTableViewCell
        cell.appTitleLabel.text = reversedTitlesArray[indexPath.row]
        cell.IconImageView.image = UIImage(data:reversedImagesArray[indexPath.row])
        cell.indexPath = indexPath
        let urlstr = reversedURLsArray[indexPath.row]
        cell.storeURL = NSURL(string: urlstr)!
        return cell
    }
    
    
    //tapでストアを開く
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if CheckReachability(host_name: "google.com") {
            let storeUrl: URL = URL(string: reversedURLsArray[indexPath.row])!
            if UIApplication.shared.canOpenURL(storeUrl){
                UIApplication.shared.open(storeUrl, options: [:])
            }
        }else{
            //ネットに接続されていない時
            let alertController = UIAlertController(title: NSLocalizedString("alertTitle", comment: ""), message: NSLocalizedString("internet", comment: ""), preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
            
        }
    }
    
    
    
}
