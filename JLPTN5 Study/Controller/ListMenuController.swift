//
//  ListMenuController.swift
//  JLPTN5 Study
//
//  Created by 尾野順哉 on 2020/09/16.
//  Copyright © 2020 NAOYA ONO. All rights reserved.
//

import UIKit
import RealmSwift
import GoogleMobileAds

class ListMenuController: UIViewController {

    // セルのレイアウト設定
    private let sectionInsets = UIEdgeInsets(top: 15, left: 15, bottom: 0, right: 15)
    // 1行あたりのアイテム数
    private var itemsPerRow: CGFloat = 2
    // リストタイプ（語彙か漢字か）
    var type: Int?
    // タップされたセル番号
    private var tappedCellNumber: Int?
    
    // カテゴリー一覧
    var vocabularyCategories: Results<VocabularyCategory>?
    var kanjiCategories: Results<KanjiCategory>?
        
    @IBOutlet weak var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bannerView.adUnitID = "ca-app-pub-4166043434922569/7627970789"
        bannerView.rootViewController = self
                
        initView()
        
        // 語彙or漢字一覧を取得
        loadList()
    }
    
    func initView(){
        // ナビゲーションの設定
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil) // 戻るボタンのテキストを消す
        
        // タイトル
        if self.type == 0 {
            title = "Vocabulary Lists"
        } else if self.type == 1 {
            title = "Kanji Lists"
        }
    }
     
    func loadList() {
        let realm = try! Realm()
        
        if type == 0 {
            // 語彙
            vocabularyCategories = realm.objects(VocabularyCategory.self).sorted(byKeyPath: "order", ascending: true)
            
        } else if type == 1 {
            // 漢字
            kanjiCategories = realm.objects(KanjiCategory.self).sorted(byKeyPath: "order", ascending: true)
        }
    }

    // バナー広告読み込み
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

extension ListMenuController: UICollectionViewDataSource {
    
    // セル数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if self.type == 0 {
            return vocabularyCategories?.count ?? 0
            
        } else if self.type == 1 {
            return kanjiCategories?.count ?? 0
        }

        return 0
    }
    
    // セルに値をセット
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // widthReuseIdentifierにはStoryboardで設定したセルのIDを指定
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListMenuCell", for: indexPath)
        
        // セルのラベルに値をセット
        let title = cell.contentView.viewWithTag(1) as! UILabel
        title.adjustsFontSizeToFitWidth = true
        
        if self.type == 0 {
            title.text = vocabularyCategories?[indexPath.row].name ?? "No name"
       } else if self.type == 1 {
            title.text = kanjiCategories?[indexPath.row].name ?? "No name"
        }
                
        // セルに枠線をセット
        cell.layer.cornerRadius = 10
        cell.backgroundColor = UIColor(named: "MenuButtonColor")

        // 影をセット
        cell.layer.masksToBounds = false // 溢れる分を表示
        cell.layer.shadowColor = UIColor.black.cgColor //　影の色
        cell.layer.shadowOpacity = 0.2  //影の濃さ
        cell.layer.shadowRadius = 3.0 // 影のぼかし量
        cell.layer.shadowOffset = CGSize(width: 5.0, height: 5.0) // 影の方向
        
        return cell
    }
}

// セルをタップしたときの処理
extension ListMenuController: UICollectionViewDelegate {
    // セルがタップされた時の処理
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath)
        
        // セルの拡大・縮小のアニメーション
        UIView.animate(
            // セルを縮小する
            withDuration: 0.1,
            delay: 0,
            options: [.curveEaseOut],
            animations: {
                cell!.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        })
        { finished in
            // セルを拡大する
            UIView.animate(
                withDuration: 0.1,
                delay: 0,
                options: [.curveEaseIn],
                animations: {
                    cell!.transform = CGAffineTransform.identity
            }) { finished in
                //タップされたセル番号を保持
                self.tappedCellNumber = indexPath.row
                
                // リストページへ移動
                self.performSegue(withIdentifier: "goToListPage", sender: nil)
            }
        }
    }
    
    // 次の画面に渡す変数
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
                
        if segue.identifier == "goToListPage" {
            // 対象の画面（クイズ画面）
            let destioantionVC = segue.destination as! ListController

            // クイズタイプ（語彙 or　漢字）
            destioantionVC.type = type
                                    
            // タップされたカテゴリーの単語一覧を渡す
            if self.type == 0 {
                destioantionVC.vocabularyList = vocabularyCategories![tappedCellNumber!]
            } else if type == 1 {
                destioantionVC.kanjiList = kanjiCategories![tappedCellNumber!]
            }
        }
    }

}

// セルのサイズを調整する
extension ListMenuController: UICollectionViewDelegateFlowLayout {
    
    // Screenサイズに応じたセルサイズを返す
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem/3)
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

