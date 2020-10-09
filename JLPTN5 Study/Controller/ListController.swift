//
//  ListController.swift
//  JLPTN5 Study
//
//  Created by 尾野順哉 on 2020/09/16.
//  Copyright © 2020 NAOYA ONO. All rights reserved.
//

import UIKit
import RealmSwift
import AVFoundation
import GoogleMobileAds

class ListController: UIViewController {

    // セルのレイアウト設定
    private let sectionInsets = UIEdgeInsets(top: 15, left: 15, bottom: 0, right: 15)
    // 1行あたりのアイテム数
    private var itemsPerRow: CGFloat = 1
    // リストタイプ（語彙か漢字か文法か）
    var type: Int?

    var audioPlayer:AVAudioPlayer!
    
    // カテゴリー一覧
    var vocabularyList: VocabularyCategory?
    var kanjiList: KanjiCategory?
    var grammarList: Results<GrammarList>?
        
    @IBOutlet weak var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bannerView.adUnitID = "ca-app-pub-4166043434922569/7627970789"
        bannerView.rootViewController = self
        
        initView()
        
        if self.type == 2 {
            loadGrammarData()
        }
    }
    
    func initView(){
        switch self.type {
        case 0:
            title = vocabularyList?.name ?? "No Title"
        case 1:
            title = kanjiList?.name ?? "No Title"
        case 2:
            title = "Grammar Patterns"
        default:
            print("該当無し")
        }
    }
    
    func loadGrammarData() {
        let realm = try! Realm()
        grammarList = realm.objects(GrammarList.self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      loadBannerAd()
    }
    
    override func viewWillTransition(to size: CGSize,
                            with coordinator: UIViewControllerTransitionCoordinator) {
      super.viewWillTransition(to:size, with:coordinator)
      coordinator.animate(alongsideTransition: { _ in
        self.loadBannerAd()
      })
    }
    
    func loadBannerAd() {
      let frame = { () -> CGRect in
        if #available(iOS 11.0, *) {
          return view.frame.inset(by: view.safeAreaInsets)
        } else {
          return view.frame
        }
      }()
      let viewWidth = frame.size.width

      bannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
      bannerView.load(GADRequest())
    }
}

extension ListController: UICollectionViewDataSource {
    
    // セル数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        switch self.type {
        case 0:
            return vocabularyList?.items.count ?? 0
        case 1:
            return kanjiList?.items.count ?? 0
        case 2:
            return grammarList?.count ?? 0
        default:
            return 0
        }
    }
    
    // セルに値をセット
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // widthReuseIdentifierにはStoryboardで設定したセルのIDを指定
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListMenuCell", for: indexPath)
        
        // セルのラベルに値をセット
        let leftTitle = cell.contentView.viewWithTag(2) as! UILabel
        let rightTitle = cell.contentView.viewWithTag(3) as! UILabel
        let speakerView = cell.contentView.viewWithTag(4)
        
        speakerView?.isHidden = true
        
        switch self.type {
        case 0:
            leftTitle.text = vocabularyList?.items[indexPath.row].japanese ?? "No name"
            rightTitle.text = vocabularyList?.items[indexPath.row].english ?? "No name"
        case 1:
            leftTitle.text = kanjiList?.items[indexPath.row].kanji ?? "No name"
            rightTitle.text = kanjiList?.items[indexPath.row].reading ?? "No name"
        case 2:
            leftTitle.text = grammarList?[indexPath.row].japanese ?? "No name"
            rightTitle.text = grammarList?[indexPath.row].english ?? "No name"
            speakerView?.isHidden = true
        default:
            print("該当無し")
        }
        
        // ラベルのサイズ調整
        leftTitle.adjustsFontSizeToFitWidth = true
        rightTitle.adjustsFontSizeToFitWidth = true
                
        // セルに枠線をセット
        cell.layer.cornerRadius = 10
        cell.backgroundColor = UIColor(named: "MenuButtonColor")

        // 影をセット
        cell.layer.masksToBounds = false // 溢れる分を表示
        cell.layer.shadowColor = UIColor.black.cgColor //　影の色
        cell.layer.shadowOpacity = 0.3  //影の濃さ
        cell.layer.shadowRadius = 2.0 // 影のぼかし量
        cell.layer.shadowOffset = CGSize(width: 1.0, height: 1.0) // 影の方向
        
        return cell
    }    
}

// セルをタップしたときの処理
extension ListController: UICollectionViewDelegate {
    // セルがタップされた時の処理（次のバージョンで対応）
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//
//        let cell = collectionView.cellForItem(at: indexPath)
//
//        // セルの拡大・縮小のアニメーション
//        UIView.animate(
//            // セルを縮小する
//            withDuration: 0.1,
//            delay: 0,
//            options: [.curveEaseOut],
//            animations: {
//                cell!.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
//        })
//        { finished in
//            // セルを拡大する
//            UIView.animate(
//                withDuration: 0.1,
//                delay: 0,
//                options: [.curveEaseIn],
//                animations: {
//                    cell!.transform = CGAffineTransform.identity
//            }) { finished in
//
//                // 音を鳴らす
//                if self.type == 0 {
//                    self.soundPlay(self.vocabularyList!.items[indexPath.row].sound)
//
//                } else if self.type == 1 {
//                    self.soundPlay(self.kanjiList!.items[indexPath.row].sound)
//                }
//            }
//        }
//    }
    
    func soundPlay(_ name: String) {
                
         // ② 音楽ファイルを取得。ファイルがなければ以降の処理を中断
         guard let soundFile = NSDataAsset(name: name) else {
           print("Not Found")
           return
         }

         // ③ 音楽プレイヤーを生成（AVAudioPlayerのインスタンス化）
         audioPlayer = try! AVAudioPlayer(data:soundFile.data, fileTypeHint:"mp3")

         // ④ 音楽ファイルの再生
         audioPlayer!.play()
    }
}

// セルのサイズを調整する
extension ListController: UICollectionViewDelegateFlowLayout {
    
    // Screenサイズに応じたセルサイズを返す
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: 55)
    }
    
    // 周囲の余白
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    // セルの行間の設定
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15.0
    }
}
