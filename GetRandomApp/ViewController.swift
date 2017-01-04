//
//  ViewController.swift
//  GetRandomApp
//
//  Created by Family Account on 2016/10/29.
//  Copyright © 2016年 Family Account. All rights reserved.
//

import UIKit
import Kanna
import Accounts
import ActionSheetPicker_3_0

let save: UserDefaults = UserDefaults.standard


class ViewController: UIViewController{
    
    @IBOutlet var backgroundLabel: UILabel!
    @IBOutlet var appIconImageView: UIImageView!
    @IBOutlet var appTitleLabel: UILabel!
    @IBOutlet var searchBtn: UIButton!
    @IBOutlet var showBtn: UIButton!
    @IBOutlet var selectBtn: UIButton!
    @IBOutlet var shareBtn: UIBarButtonItem!
    
    var storeURL: URL!
    var pageURL: URL!
    var index: Int!
    
    let functions:[(ViewController) -> (Void) -> URL] = [book,business,catalog,education,entertainment,finance,food,game,health,lifeStyle,magazine,medical,music,navigation,news,photo,productivity,dictionary,shopping,sns,sports,travel,utilities,weather]
    let alphabet: [String] = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","*"]
    var URLsArray:[String] = []
    var appImagesURLArray:[String] = []
    var iconImagesArray: [UIImage] = []
    var appTitleArray: [String] = []
    var appURLArray: [String] = []
    var dataOfImages: [Data] = []
    let categoryArray: [String] = [
        NSLocalizedString("allCategories", comment: ""),
        NSLocalizedString("category1", comment: ""),
        NSLocalizedString("category2", comment: ""),
        NSLocalizedString("category3", comment: ""),
        NSLocalizedString("category4", comment: ""),
        NSLocalizedString("category5", comment: ""),
        NSLocalizedString("category6", comment: ""),
        NSLocalizedString("category7", comment: ""),
        NSLocalizedString("category8", comment: ""),
        NSLocalizedString("category9", comment: ""),
        NSLocalizedString("category10", comment: ""),
        NSLocalizedString("category11", comment: ""),
        NSLocalizedString("category12", comment: ""),
        NSLocalizedString("category13", comment: ""),
        NSLocalizedString("category14", comment: ""),
        NSLocalizedString("category15", comment: ""),
        NSLocalizedString("category16", comment: ""),
        NSLocalizedString("category17", comment: ""),
        NSLocalizedString("category18", comment: ""),
        NSLocalizedString("category19", comment: ""),
        NSLocalizedString("category20", comment: ""),
        NSLocalizedString("category21", comment: ""),
        NSLocalizedString("category22", comment: ""),
        NSLocalizedString("category23", comment: ""),
        NSLocalizedString("category24", comment: ""),
        ]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //UI
        backgroundLabel.layer.cornerRadius = 20
        backgroundLabel.layer.borderColor = UIColor.lightGray.cgColor
        backgroundLabel.layer.borderWidth = 0.5
        backgroundLabel.layer.masksToBounds = true
        
        appTitleLabel.numberOfLines = 0
        searchBtn.layer.cornerRadius = 10
        showBtn.isEnabled = false
        shareBtn.isEnabled = false
        
        appIconImageView.layer.borderColor = UIColor.lightGray.cgColor
        appIconImageView.layer.borderWidth = 0.5
        appIconImageView.layer.cornerRadius = 33
        appIconImageView.layer.masksToBounds = true
        
        appTitleLabel.adjustsFontSizeToFitWidth = true
        
        self.navigationItem.title = NSLocalizedString("title1", comment: "")
        showBtn.setTitle(NSLocalizedString("appstore", comment: ""), for: UIControlState.normal)
        selectBtn.setTitle(NSLocalizedString("picker", comment: ""), for: UIControlState.normal)
        
        self.selectBtn.contentVerticalAlignment = UIControlContentVerticalAlignment.fill
        
        //データ読み込み
        if save.object(forKey: "images") != nil{
            let tmpData = save.object(forKey: "images") as! Array<Data>
            for i in 0..<tmpData.count {
                let tmpImage = UIImage(data: tmpData[i])!
                iconImagesArray.append(tmpImage)
            }
            appTitleArray = save.object(forKey: "titles") as! [String]
            appURLArray = save.object(forKey: "URLs") as! [String]
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        
        if selectBtn.titleLabel?.text == NSLocalizedString("picker", comment: ""){
            searchBtn.isEnabled = false
            searchBtn.backgroundColor = UIColor(red:0.82, green:0.82, blue:0.82, alpha:1.00)
        }
        
        
    }
    
    
    
    @IBAction func search(){
        
        if CheckReachability(host_name: "google.com") {
            
            searchBtn.isEnabled = false
            selectBtn.isEnabled = false
            searchBtn.backgroundColor = UIColor(red:0.82, green:0.82, blue:0.82, alpha:1.00)
            dispatch_async_global {
                //ページからURL一件取得
                if self.URLsArray.count != 0{
                    self.URLsArray.removeAll()
                }
                if self.index == 0{
                    self.pageURL = self.allCategory()
                }else{
                    self.pageURL = self.functions[self.index - 1](self)()
                }
                let url: URL = self.pageURL
                let data: Data = try! Data(contentsOf: url)
                let doc: HTMLDocument = HTML(html: data, encoding: .utf8)!
                for node in doc.css("div#main div#content div#selectedgenre div#selectedcontent a") {
                    self.URLsArray.append(node["href"]! as String)
                }
                print("URL総数は" + String(self.URLsArray.count))
                var randomUrlRand:Int = Int(arc4random_uniform(UInt32(self.URLsArray.count + 1)))
                if randomUrlRand == self.URLsArray.count{
                    randomUrlRand -= 1
                }
                print("乱数は" + String(randomUrlRand))
                print(self.URLsArray[randomUrlRand])
                self.appURLArray.append(self.URLsArray[randomUrlRand])
                self.storeURL = URL(string:self.URLsArray[randomUrlRand])
                
                //アプリのアイコン画像のURLを取得
                let imagesUrl: URL = URL(string: self.URLsArray[randomUrlRand])!
                let imagesData: Data = try! Data(contentsOf: imagesUrl )
                let imagesDoc: HTMLDocument = HTML(html: imagesData, encoding: .utf8)!
                let node = imagesDoc.css("div#main div#desktopContentBlockId div#content div#title h1").first
                let appTitle: String = (node?.innerHTML)!
                print("アプリ名は " + appTitle + "\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
                for node in imagesDoc.css("div#main div#desktopContentBlockId div#content div#left-stack meta") {
                    self.appImagesURLArray.append(node["content"]!)
                }
                
                let req: NSURLRequest = NSURLRequest(url: URL(string: self.appImagesURLArray[self.appImagesURLArray.count - 1])!)
                NSURLConnection.sendAsynchronousRequest(req as URLRequest, queue:OperationQueue.main){res, data, err in
                    self.dispatch_async_main {
                        self.showBtn.isEnabled = true
                        self.selectBtn.isEnabled = true
                        self.shareBtn.isEnabled = true
                        self.appTitleLabel.text = appTitle
                        self.appTitleArray.append(appTitle)
                        let image: UIImage = UIImage(data:data!)!
                        self.appIconImageView.image = image
                        self.iconImagesArray.append(image)
                        if self.iconImagesArray.count >= 31{
                            self.appTitleArray.remove(at: 0)
                            self.iconImagesArray.remove(at: 0)
                            self.appURLArray.remove(at: 0)
                        }
                        self.dataOfImages =  self.iconImagesArray.map {(image) -> Data in
                            UIImagePNGRepresentation(image)!}
                        save.set(self.dataOfImages, forKey: "images")
                        save.set(self.appTitleArray, forKey: "titles")
                        save.set(self.appURLArray, forKey: "URLs")
                        self.searchBtn.isEnabled = true
                        self.searchBtn.backgroundColor = UIColor(red:0.00, green:0.55, blue:0.96, alpha:1.00)
                        
                    }
                }
            }
        }else {
            //ネットに接続されていない時
            let alertController = UIAlertController(title: NSLocalizedString("alertTitle", comment: ""), message: NSLocalizedString("internet", comment: ""), preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
            
        }
    }
    //storeで見る
    @IBAction func show(){
        if CheckReachability(host_name: "google.com") {
           
            if UIApplication.shared.canOpenURL(storeURL){
                UIApplication.shared.open(storeURL, options: [:])
            }
        }else{
            let alertController = UIAlertController(title: NSLocalizedString("alertTitle", comment: ""), message: NSLocalizedString("internet", comment: ""), preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
            
        }
    }
    
    //カテゴリの選択
    @IBAction func choice(){
        ActionSheetStringPicker.show(withTitle: NSLocalizedString("categorySelect", comment: ""), rows: categoryArray, initialSelection: 1, doneBlock:{picker, values, indexes in
            self.searchBtn.backgroundColor = UIColor(red:0.00, green:0.55, blue:0.96, alpha:1.00)
            self.searchBtn.isEnabled = true
            self.index = values
            let str:String = indexes as! String
            if str == "Magazines & Newspapers"{
                self.selectBtn.setTitle(NSLocalizedString("category:", comment: "") + "Magazines", for: UIControlState.normal)
            }else{
                self.selectBtn.setTitle(NSLocalizedString("category:", comment: "") + str, for: UIControlState.normal)
            }
        }, cancel: {ActionMultipleStringCancelBlock in return}, origin: UIButton())
    }
    
    @IBAction func share() {
        
        // 共有する項目
        let adText = NSLocalizedString("found", comment: "")
        let shareText = appTitleLabel.text!
        let shareWebsite = storeURL!
        let shareImage = appIconImageView.image!
        
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
        self.present(activityVC, animated: true, completion: nil)
    }
    
    func allCategory() -> URL{
        let categoryRand: Int = Int(arc4random_uniform(24))
        let url:URL = functions[categoryRand](self)()
        print("カテゴリは" + categoryArray[categoryRand])
        
        return url
    }
    
    func book() -> URL{
        //ios-bukku/id6018
        let random: Int = Int(arc4random_uniform(27))
        let pagesArray: [Int] = [30,23,23,16,11,13,15,15,9,7,10,18,22,9,8,21,4,11,27,21,4,5,10,1,3,2,2]
        let pageNum: Int = pagesArray[random]
        let alpha: String = String(alphabet[random])
        let tmpPage: Int = Int(arc4random_uniform(UInt32(pageNum)))
        let page: String = String(tmpPage + 1)
        let url: URL = URL(string: "https://itunes.apple.com/jp/genre/ios-bukku/id6018?mt=8&letter=" + alpha + "&page=" + page + "#page")!
        print("アルファベット" + alphabet[random])
        print("ページ" + String(page))
        
        return url
    }
    
    func business() -> URL{
        //ios-bijinesu/id6000
        let random: Int = Int(arc4random_uniform(27))
        let pagesArray: [Int] = [83,60,86,42,43,43,39,36,39,18,22,36,77,30,24,59,8,40,101,55,14,26,29,4,6,7,22]
        let pageNum: Int = pagesArray[random]
        let alpha: String = String(alphabet[random])
        let tmpPage: Int = Int(arc4random_uniform(UInt32(pageNum)))
        let page: String = String(tmpPage + 1)
        let url: URL = URL(string: "https://itunes.apple.com/jp/genre/ios-bijinesu/id6000?mt=8&letter=" + alpha + "&page=" + page + "#page")!
        print("アルファベット" + alphabet[random])
        print("ページ" + String(page))
        
        return url
    }
    
    func catalog() -> URL{
        //ios-katarogu/id6022
        let random: Int = Int(arc4random_uniform(27))
        let pagesArray: [Int] = [9,8,12,5,5,6,6,5,4,2,3,5,10,4,3,8,1,5,11,6,2,4,4,1,1,1,3]
        let pageNum: Int = pagesArray[random]
        let alpha: String = String(alphabet[random])
        let tmpPage: Int = Int(arc4random_uniform(UInt32(pageNum)))
        let page: String = String(tmpPage + 1)
        let url: URL = URL(string: "https://itunes.apple.com/jp/genre/ios-katarogu/id6022?mt=8&letter=" + alpha + "&page=" + page + "#page")!
        print("アルファベット" + alphabet[random])
        print("ページ" + String(page))
        
        return url
    }
    
    func education() -> URL{
        //ios-jiao-yu/id6017
        let random: Int = Int(arc4random_uniform(27))
        let pagesArray: [Int] = [92,61,100,44,52,49,42,41,31,19,35,62,91,31,19,70,10,33,109,64,19,21,35,2,8,5,35]
        let pageNum: Int = pagesArray[random]
        let alpha: String = String(alphabet[random])
        let tmpPage: Int = Int(arc4random_uniform(UInt32(pageNum)))
        let page: String = String(tmpPage + 1)
        let url: URL = URL(string: "https://itunes.apple.com/jp/genre/ios-jiao-yu/id6017?mt=8&letter=" + alpha + "&page=" + page + "#page")!
        print("アルファベット" + alphabet[random])
        print("ページ" + String(page))
        
        return url
    }
    
    func entertainment() -> URL{
        //ios-entateinmento/id6016
        let random: Int = Int(arc4random_uniform(27))
        let pagesArray: [Int] = [173,143,195,98,53,128,80,83,38,38,44,74,143,43,28,136,12,91,215,114,20,38,64,7,11,16,150]
        let pageNum: Int = pagesArray[random]
        let alpha: String = String(alphabet[random])
        let tmpPage: Int = Int(arc4random_uniform(UInt32(pageNum)))
        let page: String = String(tmpPage + 1)
        let url: URL = URL(string: "https://itunes.apple.com/jp/genre/ios-entateinmento/id6016?mt=8&letter=" + alpha + "&page=" + page + "#page")!
        print("アルファベット" + alphabet[random])
        print("ページ" + String(page))
        
        return url
    }
    
    func finance() -> URL{
        //ios-fainansu/id6015
        let random: Int = Int(arc4random_uniform(27))
        let pagesArray: [Int] = [18,21,27,9,10,18,9,8,9,3,6,9,23,7,6,16,2,9,26,13,5,5,7,1,2,2,5]
        let pageNum: Int = pagesArray[random]
        let alpha: String = String(alphabet[random])
        let tmpPage: Int = Int(arc4random_uniform(UInt32(pageNum)))
        let page: String = String(tmpPage + 1)
        let url: URL = URL(string: "https://itunes.apple.com/jp/genre/ios-fainansu/id6015?mt=8&letter=" + alpha + "&page=" + page + "#page")!
        print("アルファベット" + alphabet[random])
        print("ページ" + String(page))
        
        return url
    }
    
    func food() -> URL{
        //ios-fudo-dorinku/id6023
        let random: Int = Int(arc4random_uniform(27))
        let pagesArray: [Int] = [16,26,31,16,9,17,15,12,7,6,10,14,25,8,6,26,2,16,30,17,3,7,10,1,3,3,6]
        let pageNum: Int = pagesArray[random]
        let alpha: String = String(alphabet[random])
        let tmpPage: Int = Int(arc4random_uniform(UInt32(pageNum)))
        let page: String = String(tmpPage + 1)
        let url: URL = URL(string: "https://itunes.apple.com/jp/genre/ios-fudo-dorinku/id6023?mt=8&letter=" + alpha + "&page=" + page + "#page")!
        print("アルファベット" + alphabet[random])
        print("ページ" + String(page))
        
        return url
    }
    
    func game() -> URL{
        //ios-gemu/id6014
        let random: Int = Int(arc4random_uniform(27))
        let pagesArray: [Int] = [189,164,218,105,51,146,83,81,29,45,43,71,149,40,23,142,13,75,240,114,17,26,64,6,8,20,149]
        let pageNum: Int = pagesArray[random]
        let alpha: String = String(alphabet[random])
        let tmpPage: Int = Int(arc4random_uniform(UInt32(pageNum)))
        let page: String = String(tmpPage + 1)
        let url: URL = URL(string: "https://itunes.apple.com/jp/genre/ios-gemu/id6014?mt=8&letter=" + alpha + "&page=" + page + "#page")!
        print("アルファベット" + alphabet[random])
        print("ページ" + String(page))
        
        return url
    }
    
    func health() -> URL{
        //ios-herusukea-fittonesu/id6013
        let random: Int = Int(arc4random_uniform(27))
        let pagesArray: [Int] = [27,32,30,20,15,25,16,23,11,5,8,14,37,12,8,30,3,17,42,19,5,9,13,1,7,3,13]
        let pageNum: Int = pagesArray[random]
        let alpha: String = String(alphabet[random])
        let tmpPage: Int = Int(arc4random_uniform(UInt32(pageNum)))
        let page: String = String(tmpPage + 1)
        let url: URL = URL(string: "https://itunes.apple.com/jp/genre/ios-herusukea-fittonesu/id6013?mt=8&letter=" + alpha + "&page=" + page + "#page")!
        print("アルファベット" + alphabet[random])
        print("ページ" + String(page))
        
        return url
    }
    
    func lifeStyle() -> URL{
        //ios-raifusutairu/id6012
        let random: Int = Int(arc4random_uniform(27))
        let pagesArray: [Int] = [82,91,113,59,41,69,55,66,32,22,33,60,102,36,25,81,10,53,129,68,15,31,46,3,12,9,38]
        let pageNum: Int = pagesArray[random]
        let alpha: String = String(alphabet[random])
        let tmpPage: Int = Int(arc4random_uniform(UInt32(pageNum)))
        let page: String = String(tmpPage + 1)
        let url: URL = URL(string: "https://itunes.apple.com/jp/genre/ios-raifusutairu/id6012?mt=8&letter=" + alpha + "&page=" + page + "#page")!
        print("アルファベット" + alphabet[random])
        print("ページ" + String(page))
        
        return url
    }
    
    func magazine() -> URL{
        //ios-za-zhi-xin-wen/id6021
        let random: Int = Int(arc4random_uniform(27))
        let pagesArray: [Int] = [6,4,7,4,3,4,4,3,3,2,2,3,6,3,2,5,1,4,6,4,1,2,3,1,1,1,3]
        let pageNum: Int = pagesArray[random]
        let alpha: String = String(alphabet[random])
        let tmpPage: Int = Int(arc4random_uniform(UInt32(pageNum)))
        let page: String = String(tmpPage + 1)
        let url: URL = URL(string: "https://itunes.apple.com/jp/genre/ios-za-zhi-xin-wen/id6021?mt=8&letter=" + alpha + "&page=" + page  + "#page")!
        print("アルファベット" + alphabet[random])
        print("ページ" + String(page))
        
        return url
    }
    
    func medical() -> URL{
        //ios-medikaru/id6020
        let random: Int = Int(arc4random_uniform(27))
        let pagesArray: [Int] = [20,14,21,16,11,10,8,13,8,3,4,7,25,9,7,21,2,9,21,9,4,7,4,1,2,2,6]
        let pageNum: Int = pagesArray[random]
        let alpha: String = String(alphabet[random])
        let tmpPage: Int = Int(arc4random_uniform(UInt32(pageNum)))
        let page: String = String(tmpPage + 1)
        let url: URL = URL(string: "https://itunes.apple.com/jp/genre/ios-medikaru/id6020?mt=8&letter=" + alpha + "&page=" + page  + "#page")!
        print("アルファベット" + alphabet[random])
        print("ページ" + String(page))
        
        return url
    }
    
    func music() -> URL{
        //ios-myujikku/id6011
        let random: Int = Int(arc4random_uniform(27))
        let pagesArray: [Int] = [19,19,22,18,9,16,12,11,6,7,11,12,30,8,6,18,2,45,30,17,4,7,10,2,2,2,13]
        let pageNum: Int = pagesArray[random]
        let alpha: String = String(alphabet[random])
        let tmpPage: Int = Int(arc4random_uniform(UInt32(pageNum)))
        let page: String = String(tmpPage + 1)
        let url: URL = URL(string: "https://itunes.apple.com/jp/genre/ios-myujikku/id6011?mt=8&letter=" + alpha + "&page=" + page  + "#page")!
        print("アルファベット" + alphabet[random])
        print("ページ" + String(page))
        
        return url
    }
    
    func navigation() -> URL{
        //ios-nabigeshon/id6010
        let random: Int = Int(arc4random_uniform(27))
        let pagesArray: [Int] = [17,17,17,8,5,9,13,8,6,3,6,10,23,14,9,13,2,8,23,17,4,6,8,1,2,2,2]
        let pageNum: Int = pagesArray[random]
        let alpha: String = String(alphabet[random])
        let tmpPage: Int = Int(arc4random_uniform(UInt32(pageNum)))
        let page: String = String(tmpPage + 1)
        let url: URL = URL(string: "https://itunes.apple.com/jp/genre/ios-nabigeshon/id6010?mt=8&letter=" + alpha + "&page=" + page  + "#page")!
        print("アルファベット" + alphabet[random])
        print("ページ" + String(page))
        
        return url
    }
    
    func news() -> URL{
        //ios-nyusu/id6009
        let random: Int = Int(arc4random_uniform(27))
        let pagesArray: [Int] = [19,14,18,11,9,12,10,9,8,4,9,11,18,14,6,14,2,14,21,16,5,7,11,1,2,2,7]
        let pageNum: Int = pagesArray[random]
        let alpha: String = String(alphabet[random])
        let tmpPage: Int = Int(arc4random_uniform(UInt32(pageNum)))
        let page: String = String(tmpPage + 1)
        let url: URL = URL(string: "https://itunes.apple.com/jp/genre/ios-nyusu/id6009?mt=8&letter=" + alpha + "&page=" + page  + "#page")!
        print("アルファベット" + alphabet[random])
        print("ページ" + String(page))
        
        return url
    }
    
    func photo() -> URL{
        //ios-xie-zhen-bideo/id6008
        let random: Int = Int(arc4random_uniform(27))
        let pagesArray: [Int] = [17,16,28,11,8,23,11,11,12,4,6,13,23,6,4,44,2,9,32,15,3,13,10,2,2,2,7]
        let pageNum: Int = pagesArray[random]
        let alpha: String = String(alphabet[random])
        let tmpPage: Int = Int(arc4random_uniform(UInt32(pageNum)))
        let page: String = String(tmpPage + 1)
        let url: URL = URL(string: "https://itunes.apple.com/jp/genre/ios-xie-zhen-bideo/id6008?mt=8&letter=" + alpha + "&page=" + page  + "#page")!
        print("アルファベット" + alphabet[random])
        print("ページ" + String(page))
        
        return url
    }
    
    func productivity() -> URL{
        //ios-shi-shi-xiao-lu-hua/id6007
        let random: Int = Int(arc4random_uniform(27))
        let pagesArray: [Int] = [40,28,53,24,23,27,21,18,19,7,11,20,45,16,12,41,7,22,63,38,8,15,18,3,3,4,12]
        let pageNum: Int = pagesArray[random]
        let alpha: String = String(alphabet[random])
        let tmpPage: Int = Int(arc4random_uniform(UInt32(pageNum)))
        let page: String = String(tmpPage + 1)
        let url: URL = URL(string: "https://itunes.apple.com/jp/genre/ios-shi-shi-xiao-lu-hua/id6007?mt=8&letter=" + alpha + "&page=" + page  + "#page")!
        print("アルファベット" + alphabet[random])
        print("ページ" + String(page))
        
        return url
    }
    
    func dictionary() -> URL{
        //ios-ci-shu-ci-dian-sono-ta/id6006
        let random: Int = Int(arc4random_uniform(27))
        let pagesArray: [Int] = [36,27,43,21,20,20,23,21,15,8,10,21,15,8,10,21,32,15,9,32,6,16,39,24,9,10,17,1,3,2,13]
        let pageNum: Int = pagesArray[random]
        let alpha: String = String(alphabet[random])
        let tmpPage: Int = Int(arc4random_uniform(UInt32(pageNum)))
        let page: String = String(tmpPage + 1)
        let url: URL = URL(string: "https://itunes.apple.com/jp/genre/ios-ci-shu-ci-dian-sono-ta/id6006?mt=8&letter=" + alpha + "&page=" + page  + "#page")!
        print("アルファベット" + alphabet[random])
        print("ページ" + String(page))
        
        return url
    }
    
    func shopping() -> URL{
        //ios-shoppingu/id6024
        let random: Int = Int(arc4random_uniform(27))
        let pagesArray: [Int] = [6,8,27,5,3,5,5,4,2,2,3,4,8,3,3,6,1,3,12,5,2,3,3,1,1,1,3]
        let pageNum: Int = pagesArray[random]
        let alpha: String = String(alphabet[random])
        let tmpPage: Int = Int(arc4random_uniform(UInt32(pageNum)))
        let page: String = String(tmpPage + 1)
        let url: URL = URL(string: "https://itunes.apple.com/jp/genre/ios-shoppingu/id6024?mt=8&letter=" + alpha + "&page=" + page  + "#page")!
        print("アルファベット" + alphabet[random])
        print("ページ" + String(page))
        
        return url
    }
    
    func sns() -> URL{
        //ios-sosharunettowakingu/id6005
        let random: Int = Int(arc4random_uniform(27))
        let pagesArray: [Int] = [17,18,25,11,9,20,14,12,10,5,7,12,22,9,6,22,3,11,35,21,5,9,11,1,4,3,8]
        let pageNum: Int = pagesArray[random]
        let alpha: String = String(alphabet[random])
        let tmpPage: Int = Int(arc4random_uniform(UInt32(pageNum)))
        let page: String = String(tmpPage + 1)
        let url: URL = URL(string: "https://itunes.apple.com/jp/genre/ios-sosharunettowakingu/id6005?mt=8&letter=" + alpha + "&page=" + page  + "#page")!
        print("アルファベット" + alphabet[random])
        print("ページ" + String(page))
        
        return url
    }
    
    func sports() -> URL{
        //ios-supotsu/id6004
        let random: Int = Int(arc4random_uniform(27))
        let pagesArray: [Int] = [21,28,26,13,11,28,19,14,7,5,8,13,22,10,7,21,2,18,48,25,6,7,12,1,3,2,10]
        let pageNum: Int = pagesArray[random]
        let alpha: String = String(alphabet[random])
        let tmpPage: Int = Int(arc4random_uniform(UInt32(pageNum)))
        let page: String = String(tmpPage + 1)
        let url: URL = URL(string: "https://itunes.apple.com/jp/genre/ios-supotsu/id6004?mt=8&letter=" + alpha + "&page=" + page  + "#page")!
        print("アルファベット" + alphabet[random])
        print("ページ" + String(page))
        
        return url
    }
    
    func travel() -> URL{
        //ios-lu-xing/id6003
        let random: Int = Int(arc4random_uniform(27))
        let pagesArray: [Int] = [41,35,45,19,18,21,26,24,14,7,12,28,42,22,14,30,3,20,50,47,8,18,18,1,6,4,7]
        let pageNum: Int = pagesArray[random]
        let alpha: String = String(alphabet[random])
        let tmpPage: Int = Int(arc4random_uniform(UInt32(pageNum)))
        let page: String = String(tmpPage + 1)
        let url: URL = URL(string: "https://itunes.apple.com/jp/genre/ios-lu-xing/id6003?mt=8&letter=" + alpha + "&page=" + page  + "#page")!
        print("アルファベット" + alphabet[random])
        print("ページ" + String(page))
        
        return url
    }
    
    func utilities() -> URL{
        //ios-yutiriti/id6002
        let random: Int = Int(arc4random_uniform(27))
        let pagesArray: [Int] = [57,45,78,35,32,40,33,26,24,9,16,31,68,22,15,61,10,34,91,55,13,22,29,4,5,5,16]
        let pageNum: Int = pagesArray[random]
        let alpha: String = String(alphabet[random])
        let tmpPage: Int = Int(arc4random_uniform(UInt32(pageNum)))
        let page: String = String(tmpPage + 1)
        let url: URL = URL(string: "https://itunes.apple.com/jp/genre/ios-yutiriti/id6002?mt=8&letter=" + alpha + "&page=" + page  + "#page")!
        print("アルファベット" + alphabet[random])
        print("ページ" + String(page))
        
        return url
    }
    
    func weather() -> URL{
        //ios-tian-qi/id6001
        let random: Int = Int(arc4random_uniform(27))
        let pagesArray: [Int] = [3,2,3,2,1,2,1,2,1,1,2,2,3,2,1,2,1,2,5,3,1,1,8,1,1,1,1]
        let pageNum: Int = pagesArray[random]
        let alpha: String = String(alphabet[random])
        let tmpPage: Int = Int(arc4random_uniform(UInt32(pageNum)))
        let page: String = String(tmpPage + 1)
        let url: URL = URL(string: "https://itunes.apple.com/jp/genre/ios-tian-qi/id6001?mt=8&letter=" + alpha + "&page=" + page  + "#page")!
        print("アルファベット" + alphabet[random])
        print("ページ" + String(page))
        
        return url
    }
    
    func dispatch_async_main(block: @escaping () -> ()) {
        DispatchQueue.main.async(execute: block)
    }
    
    func dispatch_async_global(block: @escaping () -> ()) {
        DispatchQueue.global(qos: .default).async(execute: block)
    }
    
}
