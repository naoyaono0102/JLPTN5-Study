//
//  FlashCardMenuController.swift
//  JLPTN5 Study
//
//  Created by 尾野順哉 on 2020/09/14.
//  Copyright © 2020 NAOYA ONO. All rights reserved.
//

import UIKit
import RealmSwift
import GoogleMobileAds

class FlashCardMenuController: UIViewController, GADInterstitialDelegate {
    
    // セルのレイアウト設定
    private let sectionInsets = UIEdgeInsets(top: 15, left: 15, bottom: 25, right: 15)
    // 1行あたりのアイテム数
    private var itemsPerRow: CGFloat = 2
    // クイズタイプ（語彙・漢字・文法）
    var type: Int?
    // クイズモード（0：英語 / 1：日本語）
    private var quizMode: Int?
    // タップされたセル番号
    private var tappedCellNumber: Int?
    // タップされたセクション番号
    private var tappedSectionNumber: Int?
    
    // 表示するセクション
    let sectionLabels: [String] = ["", "Verb Conjugation", "Counters"]
    
    // カテゴリー一覧
    var vocabularyCategories: Results<VocabularyCategory>?
    var kanjiCategories: Results<KanjiCategory>?
    //    var grammarCategories: Results<GrammarCategory>?
    var grammarCategories: [Results<GrammarCategory>]?
    
    // 編集用モーダル
    @IBOutlet var coverView: UIView!
    @IBOutlet weak var modalView: UIView!
    @IBOutlet weak var modalButtonTop: UIButton!
    @IBOutlet weak var modalButtonBottom: UIButton!
    @IBOutlet weak var RandomButtonView: UIView!
    @IBOutlet weak var RandomButton: UIButton!
    
    
    var interstitial: GADInterstitial!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 広告を作成し読み込む
        interstitial = createAndLoadInterstitial()
        
        // Viewの初期設定
        initView()
        
        // クイズ一覧を取得
        loadFlashCardCategory()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        showModalButtonBottom()
        
        // タップしたセル番号の初期化（フラッシュカード画面から戻ってきた時に使う）
        tappedCellNumber = nil
    }
    
    // インタースティシャル広告を作成し読み込む
    func createAndLoadInterstitial() -> GADInterstitial {
        
        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-4166043434922569/5616368193")
        interstitial.delegate = self
        interstitial.load(GADRequest())
        return interstitial
    }
    
    // 広告をクリックして開いた画面を閉じた直後に呼ばれる
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        
        // 新たな広告を作成し読み込む
        interstitial = createAndLoadInterstitial()
    }
    
    func initView(){
        
        // ナビゲーションの設定
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil) // 戻るボタンのテキストを消す
        self.navigationController?.view.addSubview(self.coverView) // カバー
        
        // 語彙の学習なら
        if self.type == 0 {
            // ボタンにテキストをセット
            modalButtonTop.setTitle("English ▶︎ Japanese", for: .normal)
            modalButtonBottom.setTitle("Japanese ▶︎ English", for: .normal)
            
            title = "Vocabulary Flashcards"
        }
            // 漢字の学習なら
        else if self.type == 1 {
            // ボタンにテキストをセット
            modalButtonTop.setTitle("Reading", for: .normal)
            modalButtonBottom.setTitle("Writing", for: .normal)
            
            title = "Kanji Flashcards"
        }
            // 文法の学習なら
        else if self.type == 2 {
            modalButtonTop.setTitle("From masu from", for: .normal)
            modalButtonBottom.setTitle("From dictionary form", for: .normal)
            
            RandomButtonView.isHidden = true // ランダムボタンを非表示
            title = "Grammar Flashcards"
        }
        
        coverView.frame = CGRect(x : 0, y : 0, width : self.view.frame.width, height :  self.view.frame.height)
        coverView.center = self.view.center
        modalView.center = self.view.center
        
        // セルに枠線をセット
        RandomButton.layer.cornerRadius = 25
        
        // 影をセット
        RandomButton.layer.shadowColor = UIColor.black.cgColor //　影の色
        RandomButton.layer.shadowOpacity = 0.2  //影の濃さ
        RandomButton.layer.shadowRadius = 3.0 // 影のぼかし量
        RandomButton.layer.shadowOffset = CGSize(width: 3.0, height: 3.0) // 影の方向
    }
    
    // カテゴリー一覧を取得
    func loadFlashCardCategory()  {
        let realm = try! Realm()
        
        if type == 0 {
            // 語彙
            vocabularyCategories = realm.objects(VocabularyCategory.self).sorted(byKeyPath: "order", ascending: true)
            
        } else if type == 1 {
            // 漢字
            kanjiCategories = realm.objects(KanjiCategory.self).sorted(byKeyPath: "order", ascending: true)
        } else if type == 2 {
            // 文法
            let grammarCategories = realm.objects(GrammarCategory.self).sorted(byKeyPath: "order", ascending: true)
            let conjugations = grammarCategories.filter("type == 0")
            let patterns = grammarCategories.filter("type == 1")
            let counters = grammarCategories.filter("type == 2")
            self.grammarCategories = [patterns,conjugations,counters]
        }
    }
    
    // モーダルを閉じる
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        coverView.isHidden = true
        showModalButtonBottom()
    }
    
    // 隠れたボタンを表示
    func showModalButtonBottom() {
        if modalButtonBottom.isHidden {
            self.modalButtonBottom.isHidden = false
        }
    }
    
    // モーダルの上のボタンがクリックされた時
    @IBAction func modalButtonTopPressed(_ sender: UIButton) {
        coverView.isHidden = true
        self.quizMode = 0
        
        showInterstitialAd()
        
        // フラッシュカード画面へ遷移
        self.performSegue(withIdentifier: "goToFlashCardPage", sender: nil)
    }
    
    
    @IBAction func modalButtonBottom(_ sender: UIButton) {
        coverView.isHidden = true
        self.quizMode = 1
        
        showInterstitialAd()
        
        // フラッシュカード画面へ遷移
        self.performSegue(withIdentifier: "goToFlashCardPage", sender: nil)
    }
    
    // 広告表示（表示準備ができていれば）
    func showInterstitialAd() {
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        }
    }
    
    // 次の画面に渡す変数
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToFlashCardPage" {
            // 対象の画面（クイズ画面）
            let destioantionVC = segue.destination as! FlashcardController
            
            // クイズタイプ（語彙 or　漢字 or 文法）
            destioantionVC.type = type
            
            // クイズモードを渡す
            destioantionVC.quizMode = quizMode // 0 or 1
            
            // タップされたカテゴリーの単語一覧を渡す
            switch self.type {
            case 0:
                if tappedCellNumber != nil {
                    destioantionVC.vocabularyList = vocabularyCategories![tappedCellNumber!].items
                    destioantionVC.category = vocabularyCategories![tappedCellNumber!].name
                }else {
                    destioantionVC.category = "Random"
                    
                    // すべての単語を取得
                    let list = List<Vocabulary>()
                    for vocabularyCategory in vocabularyCategories! {
                        for vocabulary in vocabularyCategory.items {
                            list.append(vocabulary)
                        }
                    }
                    destioantionVC.vocabularyList = list
                }
            case 1:
                if tappedCellNumber != nil {
                    destioantionVC.kanjiList = kanjiCategories![tappedCellNumber!].items
                    destioantionVC.category = kanjiCategories![tappedCellNumber!].name
                } else {
                    destioantionVC.category = "Random"
                    
                    // すべての漢字を取得
                    let list = List<Kanji>()
                    for kanjiCategory in kanjiCategories! {
                        for kanji in kanjiCategory.items {
                            list.append(kanji)
                        }
                    }
                    destioantionVC.kanjiList = list
                }
            case 2:
                destioantionVC.category = grammarCategories?[tappedSectionNumber!][tappedCellNumber!].name
                destioantionVC.grammarType = grammarCategories?[tappedSectionNumber!][tappedCellNumber!].type
                
            default:
                print("該当無し")
            }
        }
    }
    
    // ランダムボタンが押された時の処理
    @IBAction func randomButtonPressed(_ sender: UIButton) {
        
        // ボタンの拡大・縮小のアニメーション
        UIView.animate(
            // セルを縮小する
            withDuration: 0.1,
            delay: 0,
            options: [.curveEaseOut],
            animations: {
                sender.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        })
        { finished in
            // セルを拡大する
            UIView.animate(
                withDuration: 0.1,
                delay: 0,
                options: [.curveEaseIn],
                animations: {
                    sender.transform = CGAffineTransform.identity
            }) { finished in
                //ランダムボタンがタップされたことを示す情報を保持
                // self.tappedCellNumber = indexPath.row
                
                // モーダルを表示
                self.coverView.isHidden = false
            }
        }
    }
}

extension FlashCardMenuController: UICollectionViewDataSource {
    
    // セクション数
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if self.type == 2 {
            return sectionLabels.count
        } else {
            return 1
        }
    }
    
    // セル数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch self.type {
        case 0:
            return vocabularyCategories?.count ?? 0
        case 1:
            return kanjiCategories?.count ?? 0
        case 2:
            return grammarCategories?[section].count ?? 0
        default:
            return 0
        }
    }
    
    // セルに値をセット
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // widthReuseIdentifierにはStoryboardで設定したセルのIDを指定
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FlashCardMenuCell", for: indexPath)
        
        // セルのラベルに値をセット
        let title = cell.contentView.viewWithTag(1) as! UILabel
        title.adjustsFontSizeToFitWidth = true
        
        switch self.type {
        case 0:
            title.text = vocabularyCategories?[indexPath.row].name ?? "No name"
        case 1:
            title.text = kanjiCategories?[indexPath.row].name ?? "No name"
        case 2:
            title.text = grammarCategories?[indexPath.section][indexPath.row].name ?? "No name"
        default:
            print("該当無し")
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
    
    // ヘッダーの設定
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        // 1. ヘッダーセクションを作成
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "GrammarHeader", for: indexPath) as? GrammarHeader else {
            fatalError("ヘッダーがありません")
        }
        
        // 2. ヘッダーセクションのラベルにテキストをセット
        if kind == UICollectionView.elementKindSectionHeader {
            header.grammarHeader.text = sectionLabels[indexPath.section]
            return header
        }
        
        return UICollectionReusableView()
    }
}

// セルをタップしたときの処理
extension FlashCardMenuController: UICollectionViewDelegate {
    // セルがタップされた時の処理
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //タップされたセクション・セル番号を保持
        self.tappedSectionNumber = indexPath.section
        self.tappedCellNumber = indexPath.row
        
        // ボタンの設定
        if self.type == 2 {
            switch self.grammarCategories?[indexPath.section][indexPath.row].name {
            case "masu form":
                // masuFromなのでボタンを１つに
                self.modalButtonTop.setTitle("Start", for: .normal)
                self.modalButtonBottom.isHidden = true
            case "dictionary form":
                // jishoFormなのでボタンを１つに
                self.modalButtonTop.setTitle("Start", for: .normal)
                self.modalButtonBottom.isHidden = true
            default:
                if self.grammarCategories?[indexPath.section][indexPath.row].type == 1 || self.grammarCategories?[indexPath.section][indexPath.row].type == 2{
                    self.modalButtonTop.setTitle("English ▶︎ Japanese", for: .normal)
                    self.modalButtonBottom.setTitle("Japanese ▶︎ English", for: .normal)
                } else {
                    self.modalButtonTop.setTitle("From masu form", for: .normal)
                    self.modalButtonBottom.setTitle("From dictionary form", for: .normal)
                }
            }
        }
        
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
                
                // モーダルを表示
                self.coverView.isHidden = false
            }
        }
    }
}

// セルのサイズを調整する
extension FlashCardMenuController: UICollectionViewDelegateFlowLayout {
    
    // Screenサイズに応じたセルサイズを返す
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if self.type == 2, indexPath.section == 0 {
            let paddingSpace = sectionInsets.left * 2
            let availableWidth = view.frame.width - paddingSpace
            let widthPerItem = availableWidth
            
            return CGSize(width: widthPerItem, height: widthPerItem/3)
        } else {
            let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
            let availableWidth = view.frame.width - paddingSpace
            let widthPerItem = availableWidth / itemsPerRow
            
            return CGSize(width: widthPerItem, height: widthPerItem/3)
        }
    }
    
    // 周囲の余白
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    // セルの行間の設定
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15.0
    }
    
    // セクションヘッダーの高さ
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        // 文法ならセクションヘッダーあり
        if self.type == 2 {
            if section == 0 {
                return CGSize.zero
            } else {
                return CGSize(width: self.view.bounds.width, height: 30)
            }
        } else {
            return CGSize.zero
        }
    }
}

