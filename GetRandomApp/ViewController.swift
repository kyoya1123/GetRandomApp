//
//  ViewController.swift
//  GetRandomApp
//
//  Created by Family Account on 2016/10/29.
//  Copyright © 2016年 Family Account. All rights reserved.
//

import UIKit
import Kanna
import CoreActionSheetPicker

let save: UserDefaults = UserDefaults.standard

class ViewController: UIViewController {

    @IBOutlet var appIconImageView: UIImageView!
    @IBOutlet var appTitleLabel: UILabel!
    @IBOutlet var searchBtn: UIButton!
    @IBOutlet var showBtn: UIButton!
    @IBOutlet var selectBtn: UIButton!
    
    var storeURL: URL!
    var pageURL: URL!
    
    let functions:[(ViewController) -> (Void) -> URL] = [book,business,catalog,education,entertainment,finance,food,game,health,lifeStyle,magazine,medical,music,navigation,news,photo,productivity,dictionary,shopping,sns,sports,travel,utilities,weather]
     let alphabet: [String] = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","*"]
    var URLsArray:[String] = []
    var appImagesURLArray:[String] = []
    var iconImagesArray: [UIImage] = []
    var appTitleArray: [String] = []
    var appURLArray: [String] = []
    var dataOfImages: [Data] = []
    let categoryArray: [String] = ["ブック","ビジネス","カタログ","教育","エンターテイメント","ファイナンス","フード・ドリンク","ゲーム","ヘルスケア・フィットネス","ライフスタイル","雑誌・新聞","メディカル","ミュージック","ナビゲーション","ニュース","写真・ビデオ","仕事効率化","辞書・辞典・その他","ショッピング","ソーシャルネットワーキング","スポーツ","旅行","ユーティリティ","天気"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appTitleLabel.numberOfLines = 0
        searchBtn.layer.cornerRadius = 10
        showBtn.isEnabled = false
        
        appIconImageView.layer.borderColor = UIColor.lightGray.cgColor
        appIconImageView.layer.borderWidth = 0.5
        appIconImageView.layer.cornerRadius = 33
        appIconImageView.layer.masksToBounds = true
        
        appTitleLabel.adjustsFontSizeToFitWidth = true
        
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
            }
    
    @IBAction func search(){
        searchBtn.isEnabled = false
        dispatch_async_global {
            //ページからURL一件取得
            if self.URLsArray.count != 0{
                self.URLsArray.removeAll()
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
            print("アプリ名は " + appTitle)
            for node in imagesDoc.css("div#main div#desktopContentBlockId div#content div#left-stack meta") {
                self.appImagesURLArray.append(node["content"]!)
            }
            
            let req: NSURLRequest = NSURLRequest(url: URL(string: self.appImagesURLArray[self.appImagesURLArray.count - 1])!)
            NSURLConnection.sendAsynchronousRequest(req as URLRequest, queue:OperationQueue.main){res, data, err in
                self.dispatch_async_main {
                    self.showBtn.isEnabled = true
                    self.appTitleLabel.text = appTitle
                    self.appTitleArray.append(appTitle)
                    let image: UIImage = UIImage(data:data!)!
                    self.appIconImageView.image = image
                    self.iconImagesArray.append(image)
                    if self.iconImagesArray.count >= 30{
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

                }
            }
        }
    }
    @IBAction func show(){
        if UIApplication.shared.canOpenURL(storeURL){
            UIApplication.shared.open(storeURL, options: [:])
        }
    }
    @IBAction func choice(){
        ActionSheetStringPicker.show(withTitle: "カテゴリの選択", rows: categoryArray, initialSelection: 1, doneBlock:{picker, values, indexes in
            self.pageURL = self.functions[values](self)()
            let str:String = indexes as! String
            self.selectBtn.setTitle("カテゴリ: " + str, for: UIControlState.normal)
            }, cancel: {ActionMultipleStringCancelBlock in return}, origin: nil)
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
        var pageNum: Int!
        switch random {
        case 0: pageNum = 30
        case 1: pageNum = 23
        case 2: pageNum = 23
        case 3: pageNum = 16
        case 4: pageNum = 11
        case 5: pageNum = 13
        case 6: pageNum = 15
        case 7: pageNum = 15
        case 8: pageNum = 9
        case 9: pageNum = 7
        case 10: pageNum = 10
        case 11: pageNum = 18
        case 12: pageNum = 22
        case 13: pageNum = 9
        case 14: pageNum = 8
        case 15: pageNum = 21
        case 16: pageNum = 4
        case 17: pageNum = 11
        case 18: pageNum = 27
        case 19: pageNum = 21
        case 20: pageNum = 4
        case 21: pageNum = 5
        case 22: pageNum = 10
        case 23: pageNum = 1
        case 24: pageNum = 3
        case 25: pageNum = 2
        case 26: pageNum = 2
        default: break
        }
        
        let alpha: String = String(alphabet[random])
        let tmpPage: Int = Int(arc4random_uniform(UInt32(pageNum)))
        let page: String = String(tmpPage + 1)
        let url = NSURL(string: "https://itunes.apple.com/jp/genre/ios-bukku/id6018?mt=8&letter=" + alpha + "&page=" + page + "#page")
        print("ページ" + String(page))
        print("アルファベット" + alphabet[random])
        return url as! URL
    }
    
    func business() -> URL{
        //ios-bijinesu/id6000
        let random: Int = Int(arc4random_uniform(27))
        var pageNum: Int!
        switch random {
        case 0:pageNum = 83
        case 1:pageNum = 60
        case 2: pageNum = 86
        case 3: pageNum = 42
        case 4: pageNum = 43
        case 5: pageNum = 43
        case 6: pageNum = 39
        case 7: pageNum = 36
        case 8: pageNum = 39
        case 9: pageNum = 18
        case 10: pageNum = 22
        case 11: pageNum = 36
        case 12: pageNum = 77
        case 13: pageNum = 30
        case 14: pageNum = 24
        case 15: pageNum = 59
        case 16: pageNum = 8
        case 17: pageNum = 40
        case 18: pageNum = 101
        case 19: pageNum = 55
        case 20: pageNum = 14
        case 21: pageNum = 26
        case 22: pageNum = 29
        case 23: pageNum = 4
        case 24: pageNum = 6
        case 25: pageNum = 7
        case 26: pageNum = 22
        default: break
        }
        
        let alpha: String = String(alphabet[random])
        let tmpPage: Int = Int(arc4random_uniform(UInt32(pageNum)))
        let page: String = String(tmpPage + 1)
        let url = NSURL(string: "https://itunes.apple.com/jp/genre/ios-bijinesu/id6000?mt=8&letter=" + alpha + "&page=" + page + "#page")
        print("ページ" + String(page))
        print("アルファベット" + alphabet[random])
        
        return url as! URL
    }
    
    func catalog() -> URL{
        //ios-katarogu/id6022
        let random: Int = Int(arc4random_uniform(27))
        var pageNum: Int!
        switch random {
        case 0:pageNum = 9 //a
        case 1:pageNum = 8 //b
        case 2: pageNum = 12 //c
        case 3: pageNum = 5 //d
        case 4: pageNum = 5 //e
        case 5: pageNum = 6 //f
        case 6: pageNum = 6 //g
        case 7: pageNum = 5 //h
        case 8: pageNum = 4 //i
        case 9: pageNum = 2 //j
        case 10: pageNum = 3 //k
        case 11: pageNum = 5 //l
        case 12: pageNum = 10 //m
        case 13: pageNum = 4 //n
        case 14: pageNum = 3 //o
        case 15: pageNum = 8 //p
        case 16: pageNum = 1 //q
        case 17: pageNum = 5 //r
        case 18: pageNum = 11 //s
        case 19: pageNum = 6 //t
        case 20: pageNum = 2 //u
        case 21: pageNum = 4 //v
        case 22: pageNum = 4 //w
        case 23: pageNum = 1 //x
        case 24: pageNum = 1 //y
        case 25: pageNum = 1 //z
        case 26: pageNum = 3 //*
        default: break
        }
        
        let alpha: String = String(alphabet[random])
        let tmpPage: Int = Int(arc4random_uniform(UInt32(pageNum)))
        let page: String = String(tmpPage + 1)
        let url = NSURL(string: "https://itunes.apple.com/jp/genre/ios-katarogu/id6022?mt=8&letter=" + alpha + "&page=" + page + "#page")
        print("ページ" + String(page))
        print("アルファベット" + alphabet[random])
        
        return url as! URL
    }
    
    func education() -> URL{
        //ios-jiao-yu/id6017
        let random: Int = Int(arc4random_uniform(27))
        var pageNum: Int!
        switch random {
        case 0:pageNum = 92 //a
        case 1:pageNum = 61 //b
        case 2: pageNum = 100 //c
        case 3: pageNum = 44 //d
        case 4: pageNum = 52 //e
        case 5: pageNum = 49 //f
        case 6: pageNum = 42 //g
        case 7: pageNum = 41 //h
        case 8: pageNum = 31 //i
        case 9: pageNum = 19 //j
        case 10: pageNum = 35 //k
        case 11: pageNum = 62 //l
        case 12: pageNum = 91 //m
        case 13: pageNum = 31 //n
        case 14: pageNum = 19 //o
        case 15: pageNum = 70 //p
        case 16: pageNum = 10 //q
        case 17: pageNum = 33 //r
        case 18: pageNum = 109 //s
        case 19: pageNum = 64 //t
        case 20: pageNum = 19 //u
        case 21: pageNum = 21 //v
        case 22: pageNum = 35 //w
        case 23: pageNum = 2 //x
        case 24: pageNum = 8 //y
        case 25: pageNum = 5 //z
        case 26: pageNum = 35 //*
        default: break
        }
        
        let alpha: String = String(alphabet[random])
        let tmpPage: Int = Int(arc4random_uniform(UInt32(pageNum)))
        let page: String = String(tmpPage + 1)
        let url = NSURL(string: "https://itunes.apple.com/jp/genre/ios-jiao-yu/id6017?mt=8&letter=" + alpha + "&page=" + page + "#page")
        print("ページ" + String(page))
        print("アルファベット" + alphabet[random])
        
        return url as! URL
    }
    
    func entertainment() -> URL{
        //ios-entateinmento/id6016
        let random: Int = Int(arc4random_uniform(27))
        var pageNum: Int!
        switch random {
        case 0:pageNum = 173 //a
        case 1:pageNum = 143 //b
        case 2: pageNum = 195 //c
        case 3: pageNum = 98//d
        case 4: pageNum = 53 //e
        case 5: pageNum = 128 //f
        case 6: pageNum = 80 //g
        case 7: pageNum = 83 //h
        case 8: pageNum = 38 //i
        case 9: pageNum = 38 //j
        case 10: pageNum = 44 //k
        case 11: pageNum = 74 //l
        case 12: pageNum = 143//m
        case 13: pageNum = 43 //n
        case 14: pageNum = 28 //o
        case 15: pageNum = 136 //p
        case 16: pageNum = 12 //q
        case 17: pageNum = 91 //r
        case 18: pageNum = 215 //s
        case 19: pageNum = 114 //t
        case 20: pageNum = 20 //u
        case 21: pageNum = 38 //v
        case 22: pageNum = 64 //w
        case 23: pageNum = 7 //x
        case 24: pageNum = 11 //y
        case 25: pageNum = 16 //z
        case 26: pageNum = 150 //*
        default: break
        }
        
        let alpha: String = String(alphabet[random])
        let tmpPage: Int = Int(arc4random_uniform(UInt32(pageNum)))
        let page: String = String(tmpPage + 1)
        let url = NSURL(string: "https://itunes.apple.com/jp/genre/ios-entateinmento/id6016?mt=8&letter=" + alpha + "&page=" + page + "#page")
        print("ページ" + String(page))
        print("アルファベット" + alphabet[random])
        
        return url as! URL
    }
    
    func finance() -> URL{
        //        ios-fainansu/id6015
        let random: Int = Int(arc4random_uniform(27))
        var pageNum: Int!
        switch random {
        case 0:pageNum = 18 //a
        case 1:pageNum = 21 //b
        case 2: pageNum = 27 //c
        case 3: pageNum = 9//d
        case 4: pageNum = 10 //e
        case 5: pageNum = 18 //f
        case 6: pageNum = 9 //g
        case 7: pageNum = 8 //h
        case 8: pageNum = 9 //i
        case 9: pageNum = 3 //j
        case 10: pageNum = 6 //k
        case 11: pageNum = 9 //l
        case 12: pageNum = 23//m
        case 13: pageNum = 7 //n
        case 14: pageNum = 6 //o
        case 15: pageNum = 16 //p
        case 16: pageNum = 2 //q
        case 17: pageNum = 9 //r
        case 18: pageNum = 26 //s
        case 19: pageNum = 13 //t
        case 20: pageNum = 5 //u
        case 21: pageNum = 5 //v
        case 22: pageNum = 7 //w
        case 23: pageNum = 1 //x
        case 24: pageNum = 2 //y
        case 25: pageNum = 2 //z
        case 26: pageNum = 5 //*
        default: break
        }
        
        let alpha: String = String(alphabet[random])
        let tmpPage: Int = Int(arc4random_uniform(UInt32(pageNum)))
        let page: String = String(tmpPage + 1)
        let url = NSURL(string: "https://itunes.apple.com/jp/genre/ios-fainansu/id6015?mt=8&letter=" + alpha + "&page=" + page + "#page")
        print("ページ" + String(page))
        print("アルファベット" + alphabet[random])
        
        return url as! URL
    }
    
    func food() -> URL{
        //ios-fudo-dorinku/id6023
        let random: Int = Int(arc4random_uniform(27))
        var pageNum: Int!
        switch random {
        case 0:pageNum = 16 //a
        case 1:pageNum = 26 //b
        case 2: pageNum = 31 //c
        case 3: pageNum = 16//d
        case 4: pageNum = 9 //e
        case 5: pageNum = 17 //f
        case 6: pageNum = 15//g
        case 7: pageNum = 12 //h
        case 8: pageNum = 7 //i
        case 9: pageNum = 6 //j
        case 10: pageNum = 10 //k
        case 11: pageNum = 14 //l
        case 12: pageNum = 25//m
        case 13: pageNum = 8 //n
        case 14: pageNum = 6 //o
        case 15: pageNum = 26 //p
        case 16: pageNum = 2 //q
        case 17: pageNum = 16 //r
        case 18: pageNum = 30 //s
        case 19: pageNum = 17 //t
        case 20: pageNum = 3 //u
        case 21: pageNum = 7 //v
        case 22: pageNum = 10 //w
        case 23: pageNum = 1 //x
        case 24: pageNum = 3 //y
        case 25: pageNum = 3 //z
        case 26: pageNum = 6 //*
        default: break
        }
        
        let alpha: String = String(alphabet[random])
        let tmpPage: Int = Int(arc4random_uniform(UInt32(pageNum)))
        let page: String = String(tmpPage + 1)
        let url = NSURL(string: "https://itunes.apple.com/jp/genre/ios-fudo-dorinku/id6023?mt=8&letter=" + alpha + "&page=" + page + "#page")
        print("ページ" + String(page))
        print("アルファベット" + alphabet[random])
        
        return url as! URL
    }
    
    func game() -> URL{
        //ios-gemu/id6014
        let random: Int = Int(arc4random_uniform(27))
        var pageNum: Int!
        switch random {
        case 0:pageNum = 189 //a
        case 1:pageNum = 164 //b
        case 2: pageNum = 218 //c
        case 3: pageNum = 105//d
        case 4: pageNum = 51 //e
        case 5: pageNum = 146 //f
        case 6: pageNum = 83//g
        case 7: pageNum = 81 //h
        case 8: pageNum = 29 //i
        case 9: pageNum = 45 //j
        case 10: pageNum = 43 //k
        case 11: pageNum = 71 //l
        case 12: pageNum = 149//m
        case 13: pageNum = 40 //n
        case 14: pageNum = 23 //o
        case 15: pageNum = 142 //p
        case 16: pageNum = 13 //q
        case 17: pageNum = 75 //r
        case 18: pageNum = 240 //s
        case 19: pageNum = 114 //t
        case 20: pageNum = 17 //u
        case 21: pageNum = 26 //v
        case 22: pageNum = 64 //w
        case 23: pageNum = 6 //x
        case 24: pageNum = 8 //y
        case 25: pageNum = 20 //z
        case 26: pageNum = 149 //*
        default: break
        }
        
        let alpha: String = String(alphabet[random])
        let tmpPage: Int = Int(arc4random_uniform(UInt32(pageNum)))
        let page: String = String(tmpPage + 1)
        let url = NSURL(string: "https://itunes.apple.com/jp/genre/ios-gemu/id6014?mt=8&letter=" + alpha + "&page=" + page + "#page")
        print("ページ" + String(page))
        print("アルファベット" + alphabet[random])
        
        return url as! URL
    }
    
    func health() -> URL{
        //ios-herusukea-fittonesu/id6013
        let random: Int = Int(arc4random_uniform(27))
        var pageNum: Int!
        switch random {
        case 0:pageNum = 27 //a
        case 1:pageNum = 32 //b
        case 2: pageNum = 30 //c
        case 3: pageNum = 20//d
        case 4: pageNum = 15 //e
        case 5: pageNum = 25 //f
        case 6: pageNum = 16//g
        case 7: pageNum = 23 //h
        case 8: pageNum = 11 //i
        case 9: pageNum = 5 //j
        case 10: pageNum = 8 //k
        case 11: pageNum = 14//l
        case 12: pageNum = 37//m
        case 13: pageNum = 12 //n
        case 14: pageNum = 8 //o
        case 15: pageNum = 30 //p
        case 16: pageNum = 3 //q
        case 17: pageNum = 17 //r
        case 18: pageNum = 42 //s
        case 19: pageNum = 19 //t
        case 20: pageNum = 5 //u
        case 21: pageNum = 9 //v
        case 22: pageNum = 13 //w
        case 23: pageNum = 1 //x
        case 24: pageNum = 7 //y
        case 25: pageNum = 3 //z
        case 26: pageNum = 13 //*
        default: break
        }
        
        let alpha: String = String(alphabet[random])
        let tmpPage: Int = Int(arc4random_uniform(UInt32(pageNum)))
        let page: String = String(tmpPage + 1)
        let url = NSURL(string: "https://itunes.apple.com/jp/genre/ios-herusukea-fittonesu/id6013?mt=8&letter=" + alpha + "&page=" + page + "#page")
        print("ページ" + page)
        print("アルファベット" + alphabet[random])
        
        return url as! URL
    }
    
    func lifeStyle() -> URL{
        //ios-raifusutairu/id6012
        let random: Int = Int(arc4random_uniform(27))
        var pageNum: Int!
        switch random {
        case 0:pageNum = 82 //a
        case 1:pageNum = 91 //b
        case 2: pageNum = 113 //c
        case 3: pageNum = 59//d
        case 4: pageNum = 41 //e
        case 5: pageNum = 69 //f
        case 6: pageNum = 55 //g
        case 7: pageNum = 66 //h
        case 8: pageNum = 32 //i
        case 9: pageNum = 22 //j
        case 10: pageNum = 33 //k
        case 11: pageNum = 60//l
        case 12: pageNum = 102//m
        case 13: pageNum = 36 //n
        case 14: pageNum = 25 //o
        case 15: pageNum = 81 //p
        case 16: pageNum = 10 //q
        case 17: pageNum = 53 //r
        case 18: pageNum = 129 //s
        case 19: pageNum = 68 //t
        case 20: pageNum = 15 //u
        case 21: pageNum = 31 //v
        case 22: pageNum = 46 //w
        case 23: pageNum = 3 //x
        case 24: pageNum = 12 //y
        case 25: pageNum = 9 //z
        case 26: pageNum = 38 //*
        default: break
        }
        
        let alpha: String = String(alphabet[random])
        let tmpPage: Int = Int(arc4random_uniform(UInt32(pageNum)))
        let page: String = String(tmpPage + 1)
        let url = NSURL(string: "https://itunes.apple.com/jp/genre/ios-raifusutairu/id6012?mt=8&letter=" + alpha + "&page=" + page + "#page")
        print("ページ" + String(page))
        print("アルファベット" + alphabet[random])
        
        return url as! URL
    }
    
    func magazine() -> URL{
        //ios-za-zhi-xin-wen/id6021
        let random: Int = Int(arc4random_uniform(27))
        var pageNum: Int!
        switch random {
        case 0:pageNum = 6 //a
        case 1:pageNum = 4 //b
        case 2: pageNum = 7 //c
        case 3: pageNum = 4 //d
        case 4: pageNum = 3 //e
        case 5: pageNum = 4 //f
        case 6: pageNum = 4 //g
        case 7: pageNum = 3 //h
        case 8: pageNum = 3 //i
        case 9: pageNum = 2 //j
        case 10: pageNum = 2 //k
        case 11: pageNum = 3 //l
        case 12: pageNum = 6//m
        case 13: pageNum = 3 //n
        case 14: pageNum = 2 //o
        case 15: pageNum = 5 //p
        case 16: pageNum = 1 //q
        case 17: pageNum = 4 //r
        case 18: pageNum = 6 //s
        case 19: pageNum = 4 //t
        case 20: pageNum = 1 //u
        case 21: pageNum = 2 //v
        case 22: pageNum = 3 //w
        case 23: pageNum = 1 //x
        case 24: pageNum = 1 //y
        case 25: pageNum = 1 //z
        case 26: pageNum = 3 //*
        default: break
        }
        
        let alpha: String = String(alphabet[random])
        let tmpPage: Int = Int(arc4random_uniform(UInt32(pageNum)))
        let page: String = String(tmpPage + 1)
        let url = NSURL(string: "https://itunes.apple.com/jp/genre/ios-za-zhi-xin-wen/id6021?mt=8&letter=" + alpha + "&page=" + page  + "#page")
        print("ページ" + String(page))
        print("アルファベット" + alphabet[random])
        
        return url as! URL
    }
    
    func medical() -> URL{
        //ios-medikaru/id6020
        let random: Int = Int(arc4random_uniform(27))
        var pageNum: Int!
        switch random {
        case 0:pageNum = 20 //a
        case 1:pageNum = 14 //b
        case 2: pageNum = 21 //c
        case 3: pageNum = 16 //d
        case 4: pageNum = 11 //e
        case 5: pageNum = 10 //f
        case 6: pageNum = 8 //g
        case 7: pageNum = 13 //h
        case 8: pageNum = 8 //i
        case 9: pageNum = 3 //j
        case 10: pageNum = 4 //k
        case 11: pageNum = 7 //l
        case 12: pageNum = 25//m
        case 13: pageNum = 9 //n
        case 14: pageNum = 7 //o
        case 15: pageNum = 21 //p
        case 16: pageNum = 2 //q
        case 17: pageNum = 9 //r
        case 18: pageNum = 21 //s
        case 19: pageNum = 9 //t
        case 20: pageNum = 4 //u
        case 21: pageNum = 7 //v
        case 22: pageNum = 4 //w
        case 23: pageNum = 1 //x
        case 24: pageNum = 2 //y
        case 25: pageNum = 2 //z
        case 26: pageNum = 6 //*
        default: break
        }
        
        let alpha: String = String(alphabet[random])
        let tmpPage: Int = Int(arc4random_uniform(UInt32(pageNum)))
        let page: String = String(tmpPage + 1)
        let url = NSURL(string: "https://itunes.apple.com/jp/genre/ios-medikaru/id6020?mt=8&letter=" + alpha + "&page=" + page  + "#page")
        print("ページ" + String(page))
        print("アルファベット" + alphabet[random])
        
        return url as! URL
    }
    
    func music() -> URL{
        //ios-myujikku/id6011
        let random: Int = Int(arc4random_uniform(27))
        var pageNum: Int!
        switch random {
        case 0:pageNum = 19 //a
        case 1:pageNum = 19 //b
        case 2: pageNum = 22 //c
        case 3: pageNum = 18 //d
        case 4: pageNum = 9 //e
        case 5: pageNum = 16 //ff
        case 6: pageNum = 12 //g
        case 7: pageNum = 11 //h
        case 8: pageNum = 6 //i
        case 9: pageNum = 7 //j
        case 10: pageNum = 11 //k
        case 11: pageNum = 12 //l
        case 12: pageNum = 30//m
        case 13: pageNum = 8 //n
        case 14: pageNum = 6 //o
        case 15: pageNum = 18 //p
        case 16: pageNum = 2 //q
        case 17: pageNum = 45 //r
        case 18: pageNum = 30 //s
        case 19: pageNum = 17 //t
        case 20: pageNum = 4 //u
        case 21: pageNum = 7 //v
        case 22: pageNum = 10 //w
        case 23: pageNum = 2 //x
        case 24: pageNum = 2 //y
        case 25: pageNum = 2 //z
        case 26: pageNum = 13 //*
        default: break
        }
        
        let alpha: String = String(alphabet[random])
        let tmpPage: Int = Int(arc4random_uniform(UInt32(pageNum)))
        let page: String = String(tmpPage + 1)
        let url = NSURL(string: "https://itunes.apple.com/jp/genre/ios-myujikku/id6011?mt=8&letter=" + alpha + "&page=" + page  + "#page")
        print("ページ" + String(page))
        print("アルファベット" + alphabet[random])
        
        return url as! URL
    }
    
    func navigation() -> URL{
        //ios-nabigeshon/id6010
        let random: Int = Int(arc4random_uniform(27))
        var pageNum: Int!
        switch random {
        case 0:pageNum = 17 //a
        case 1:pageNum = 17 //b
        case 2: pageNum = 17 //c
        case 3: pageNum = 8 //d
        case 4: pageNum = 5 //e
        case 5: pageNum = 9 //f
        case 6: pageNum = 13 //g
        case 7: pageNum = 8 //h
        case 8: pageNum = 6 //i
        case 9: pageNum = 3 //j
        case 10: pageNum = 6 //k
        case 11: pageNum = 10 //l
        case 12: pageNum = 23//m
        case 13: pageNum = 14 //n
        case 14: pageNum = 9 //o
        case 15: pageNum = 13 //p
        case 16: pageNum = 2 //q
        case 17: pageNum = 8 //r
        case 18: pageNum = 23 //s
        case 19: pageNum = 17 //t
        case 20: pageNum = 4 //u
        case 21: pageNum = 6 //v
        case 22: pageNum = 8 //w
        case 23: pageNum = 1 //x
        case 24: pageNum = 2 //y
        case 25: pageNum = 2 //z
        case 26: pageNum = 2 //*
        default: break
        }
        
        let alpha: String = String(alphabet[random])
        let tmpPage: Int = Int(arc4random_uniform(UInt32(pageNum)))
        let page: String = String(tmpPage + 1)
        let url = NSURL(string: "https://itunes.apple.com/jp/genre/ios-nabigeshon/id6010?mt=8&letter=" + alpha + "&page=" + page  + "#page")
        print("ページ" + String(page))
        print("アルファベット" + alphabet[random])
        
        return url as! URL
    }
    
    func news() -> URL{
        //ios-nyusu/id6009
        let random: Int = Int(arc4random_uniform(27))
        var pageNum: Int!
        switch random {
        case 0:pageNum = 19 //a
        case 1:pageNum = 14 //b
        case 2: pageNum = 18 //c
        case 3: pageNum = 11 //d
        case 4: pageNum = 9 //e
        case 5: pageNum = 12 //f
        case 6: pageNum = 10 //g
        case 7: pageNum = 9 //h
        case 8: pageNum = 8 //i
        case 9: pageNum = 4 //j
        case 10: pageNum = 9 //k
        case 11: pageNum = 11 //l
        case 12: pageNum = 18 //m
        case 13: pageNum = 14 //n
        case 14: pageNum = 6 //o
        case 15: pageNum = 14 //p
        case 16: pageNum = 2 //q
        case 17: pageNum = 14 //r
        case 18: pageNum = 21 //s
        case 19: pageNum = 16 //t
        case 20: pageNum = 5 //u
        case 21: pageNum = 7 //v
        case 22: pageNum = 11 //w
        case 23: pageNum = 1 //x
        case 24: pageNum = 2 //y
        case 25: pageNum = 2 //z
        case 26: pageNum = 7 //*
        default: break
        }
        
        let alpha: String = String(alphabet[random])
        let tmpPage: Int = Int(arc4random_uniform(UInt32(pageNum)))
        let page: String = String(tmpPage + 1)
        let url = NSURL(string: "https://itunes.apple.com/jp/genre/ios-nyusu/id6009?mt=8&letter=" + alpha + "&page=" + page  + "#page")
        print("ページ" + String(page))
        print("アルファベット" + alphabet[random])
        
        return url as! URL
    }
    
    func photo() -> URL{
        //ios-xie-zhen-bideo/id6008
        let random: Int = Int(arc4random_uniform(27))
        var pageNum: Int!
        switch random {
        case 0:pageNum = 17 //a
        case 1:pageNum = 16 //b
        case 2: pageNum = 28 //c
        case 3: pageNum = 11 //d
        case 4: pageNum = 8 //e
        case 5: pageNum = 23 //f
        case 6: pageNum = 11 //g
        case 7: pageNum = 11 //h
        case 8: pageNum = 12 //i
        case 9: pageNum = 4 //j
        case 10: pageNum = 6 //k
        case 11: pageNum = 13 //l
        case 12: pageNum = 23 //m
        case 13: pageNum = 6 //n
        case 14: pageNum = 4 //o
        case 15: pageNum = 44 //p
        case 16: pageNum = 2 //q
        case 17: pageNum = 9 //r
        case 18: pageNum = 32 //s
        case 19: pageNum = 15 //t
        case 20: pageNum = 3 //u
        case 21: pageNum = 13 //v
        case 22: pageNum = 10 //w
        case 23: pageNum = 2 //x
        case 24: pageNum = 2 //y
        case 25: pageNum = 2 //z
        case 26: pageNum = 7 //*
        default: break
        }
        
        let alpha: String = String(alphabet[random])
        let tmpPage: Int = Int(arc4random_uniform(UInt32(pageNum)))
        let page: String = String(tmpPage + 1)
        let url = NSURL(string: "https://itunes.apple.com/jp/genre/ios-xie-zhen-bideo/id6008?mt=8&letter=" + alpha + "&page=" + page  + "#page")
        print("ページ" + String(page))
        print("アルファベット" + alphabet[random])
        
        return url as! URL
    }
    
    func productivity() -> URL{
        //ios-shi-shi-xiao-lu-hua/id6007
        let random: Int = Int(arc4random_uniform(27))
        var pageNum: Int!
        switch random {
        case 0:pageNum = 40 //a
        case 1:pageNum = 28 //b
        case 2: pageNum = 53 //c
        case 3: pageNum = 24 //d
        case 4: pageNum = 23 //e
        case 5: pageNum = 27 //f
        case 6: pageNum = 21 //g
        case 7: pageNum = 18 //h
        case 8: pageNum = 19 //i
        case 9: pageNum = 7 //j
        case 10: pageNum = 11 //k
        case 11: pageNum = 20 //l
        case 12: pageNum = 45 //m
        case 13: pageNum = 16 //n
        case 14: pageNum = 12 //o
        case 15: pageNum = 41 //p
        case 16: pageNum = 7 //q
        case 17: pageNum = 22 //r
        case 18: pageNum = 63 //s
        case 19: pageNum = 38 //t
        case 20: pageNum = 8 //u
        case 21: pageNum = 15 //v
        case 22: pageNum = 18 //w
        case 23: pageNum = 3 //x
        case 24: pageNum = 3 //y
        case 25: pageNum = 4 //z
        case 26: pageNum = 11 //*
        default: break
        }
        
        let alpha: String = String(alphabet[random])
        let tmpPage: Int = Int(arc4random_uniform(UInt32(pageNum)))
        let page: String = String(tmpPage + 1)
        let url = NSURL(string: "https://itunes.apple.com/jp/genre/ios-shi-shi-xiao-lu-hua/id6007?mt=8&letter=" + alpha + "&page=" + page  + "#page")
        print("ページ" + String(page))
        print("アルファベット" + alphabet[random])
        
        return url as! URL
    }
    
    func dictionary() -> URL{
        //ios-ci-shu-ci-dian-sono-ta/id6006
        let random: Int = Int(arc4random_uniform(27))
        var pageNum: Int!
        switch random {
        case 0:pageNum = 36 //a
        case 1:pageNum = 27 //b
        case 2: pageNum = 43 //c
        case 3: pageNum = 21 //d
        case 4: pageNum = 20 //e
        case 5: pageNum = 20 //f
        case 6: pageNum = 23 //g
        case 7: pageNum = 21 //h
        case 8: pageNum = 15 //i
        case 9: pageNum = 8 //j
        case 10: pageNum = 10 //k
        case 11: pageNum = 21 //l
        case 12: pageNum = 32 //m
        case 13: pageNum = 15 //n
        case 14: pageNum = 9 //o
        case 15: pageNum = 32 //p
        case 16: pageNum = 6 //q
        case 17: pageNum = 16 //r
        case 18: pageNum = 39 //s
        case 19: pageNum = 24 //t
        case 20: pageNum = 9 //u
        case 21: pageNum = 10 //v
        case 22: pageNum = 17 //w
        case 23: pageNum = 1 //x
        case 24: pageNum = 3 //y
        case 25: pageNum = 2 //z
        case 26: pageNum = 13 //*
        default: break
        }
        
        let alpha: String = String(alphabet[random])
        let tmpPage: Int = Int(arc4random_uniform(UInt32(pageNum)))
        let page: String = String(tmpPage + 1)
        let url = NSURL(string: "https://itunes.apple.com/jp/genre/ios-ci-shu-ci-dian-sono-ta/id6006?mt=8&letter=" + alpha + "&page=" + page  + "#page")
        print("ページ" + String(page))
        print("アルファベット" + alphabet[random])
        
        return url as! URL
    }
    
    func shopping() -> URL{
        //ios-shoppingu/id6024
        let random: Int = Int(arc4random_uniform(27))
        var pageNum: Int!
        switch random {
        case 0:pageNum = 6 //a
        case 1:pageNum = 8 //b
        case 2: pageNum = 27 //c
        case 3: pageNum = 5 //d
        case 4: pageNum = 3 //e
        case 5: pageNum = 5 //f
        case 6: pageNum = 5 //g
        case 7: pageNum = 4 //h
        case 8: pageNum = 2 //i
        case 9: pageNum = 2 //j
        case 10: pageNum = 3 //k
        case 11: pageNum = 4 //l
        case 12: pageNum = 8 //m
        case 13: pageNum = 3 //n
        case 14: pageNum = 3 //o
        case 15: pageNum = 6 //p
        case 16: pageNum = 1 //q
        case 17: pageNum = 3 //r
        case 18: pageNum = 12 //s
        case 19: pageNum = 5 //t
        case 20: pageNum = 2 //u
        case 21: pageNum = 3 //v
        case 22: pageNum = 3 //w
        case 23: pageNum = 1 //x
        case 24: pageNum = 1 //y
        case 25: pageNum = 1 //z
        case 26: pageNum = 3 //*
        default: break
        }
        
        let alpha: String = String(alphabet[random])
        let tmpPage: Int = Int(arc4random_uniform(UInt32(pageNum)))
        let page: String = String(tmpPage + 1)
        let url = NSURL(string: "https://itunes.apple.com/jp/genre/ios-shoppingu/id6024?mt=8&letter=" + alpha + "&page=" + page  + "#page")
        print("ページ" + String(page))
        print("アルファベット" + alphabet[random])
        
        return url as! URL
    }
    
    func sns() -> URL{
        //ios-sosharunettowakingu/id6005
        let random: Int = Int(arc4random_uniform(27))
        var pageNum: Int!
        switch random {
        case 0:pageNum = 17 //a
        case 1:pageNum = 18 //b
        case 2: pageNum = 25 //c
        case 3: pageNum = 11 //d
        case 4: pageNum = 9 //e
        case 5: pageNum = 20 //f
        case 6: pageNum = 14 //g
        case 7: pageNum = 12 //h
        case 8: pageNum = 10 //i
        case 9: pageNum = 5 //j
        case 10: pageNum = 7 //k
        case 11: pageNum = 12 //l
        case 12: pageNum = 22 //m
        case 13: pageNum = 9 //n
        case 14: pageNum = 6 //o
        case 15: pageNum = 22 //p
        case 16: pageNum = 3 //q
        case 17: pageNum = 11 //r
        case 18: pageNum = 35 //s
        case 19: pageNum = 21 //t
        case 20: pageNum = 5 //u
        case 21: pageNum = 9 //v
        case 22: pageNum = 11 //w
        case 23: pageNum = 1 //x
        case 24: pageNum = 4 //y
        case 25: pageNum = 3 //z
        case 26: pageNum = 8 //*
        default: break
        }
        
        let alpha: String = String(alphabet[random])
        let tmpPage: Int = Int(arc4random_uniform(UInt32(pageNum)))
        let page: String = String(tmpPage + 1)
        let url = NSURL(string: "https://itunes.apple.com/jp/genre/ios-sosharunettowakingu/id6005?mt=8&letter=" + alpha + "&page=" + page  + "#page")
        print("ページ" + String(page))
        print("アルファベット" + alphabet[random])
        
        return url as! URL
    }
    
    func sports() -> URL{
        //ios-supotsu/id6004
        let random: Int = Int(arc4random_uniform(27))
        let pagesArray: [Int] = [21,28,26,13,11,28,19,14,7,5,8,13,22,10,7,21,2,18,48,25,6,7,12,1,3,2,10]
        let pageNum: Int = pagesArray[random]
        let alpha: String = String(alphabet[random])
        let tmpPage: Int = Int(arc4random_uniform(UInt32(pageNum)))
        let page: String = String(tmpPage + 1)
        let url = NSURL(string: "https://itunes.apple.com/jp/genre/ios-supotsu/id6004?mt=8&letter=" + alpha + "&page=" + page  + "#page")
        print("ページ" + String(page))
        print("アルファベット" + alphabet[random])
        
        return url as! URL
    }
    
    func travel() -> URL{
        //ios-lu-xing/id6003
        let random: Int = Int(arc4random_uniform(27))
        let pagesArray: [Int] = [41,35,45,19,18,21,26,24,14,7,12,28,42,22,14,30,3,20,50,47,8,18,18,1,6,4,7]
        let pageNum: Int = pagesArray[random]
        let alpha: String = String(alphabet[random])
        let tmpPage: Int = Int(arc4random_uniform(UInt32(pageNum)))
        let page: String = String(tmpPage + 1)
        let url = NSURL(string: "https://itunes.apple.com/jp/genre/ios-lu-xing/id6003?mt=8&letter=" + alpha + "&page=" + page  + "#page")
        print("ページ" + String(page))
        print("アルファベット" + alphabet[random])
        
        return url as! URL
    }
    
    func utilities() -> URL{
        //ios-yutiriti/id6002
        let random: Int = Int(arc4random_uniform(27))
        let pagesArray: [Int] = [57,45,78,35,32,40,33,26,24,9,16,31,68,22,15,61,10,34,91,55,13,22,29,4,5,5,16]
        let pageNum: Int = pagesArray[random]
        let alpha: String = String(alphabet[random])
        let tmpPage: Int = Int(arc4random_uniform(UInt32(pageNum)))
        let page: String = String(tmpPage + 1)
        let url = NSURL(string: "https://itunes.apple.com/jp/genre/ios-yutiriti/id6002?mt=8&letter=" + alpha + "&page=" + page  + "#page")
        print("ページ" + String(page))
        print("アルファベット" + alphabet[random])
        
        return url as! URL
    }
    
    func weather() -> URL{
        //ios-tian-qi/id6001
        let random: Int = Int(arc4random_uniform(27))
        let pagesArray: [Int] = [3,2,3,2,2,2,1,2,1,1,2,2,3,2,1,2,1,2,5,3,1,1,8,1,1,1,1]
        let pageNum: Int = pagesArray[random]
        let alpha: String = String(alphabet[random])
        let tmpPage: Int = Int(arc4random_uniform(UInt32(pageNum)))
        let page: String = String(tmpPage + 1)
        let url = NSURL(string: "https://itunes.apple.com/jp/genre/ios-tian-qi/id6001?mt=8&letter=" + alpha + "&page=" + page  + "#page")
        print("ページ" + String(page))
        print("アルファベット" + alphabet[random])
        
        return url as! URL
    }
    
    func dispatch_async_main(block: @escaping () -> ()) {
        DispatchQueue.main.async(execute: block)
    }
    
    func dispatch_async_global(block: @escaping () -> ()) {
        DispatchQueue.global(qos: .default).async(execute: block)
    }

}
