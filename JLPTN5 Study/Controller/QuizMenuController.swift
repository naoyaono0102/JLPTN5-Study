//
//  QuizMenuController.swift
//  JLPTN5 Study
//
//  Created by 尾野順哉 on 2020/09/14.
//  Copyright © 2020 NAOYA ONO. All rights reserved.
//

import UIKit
import RealmSwift
import GoogleMobileAds

class QuizMenuController: UIViewController, GADInterstitialDelegate {
    
    // セルのレイアウト設定
    private let sectionInsets = UIEdgeInsets(top: 15, left: 15, bottom: 0, right: 15)
    // 1行あたりのアイテム数
    private var itemsPerRow: CGFloat = 2
    // クイズタイプ（語彙か漢字か）
    var type: Int?
    // クイズモード（0：英語 / 1：日本語）
    private var quizMode: Int?
    // タップされたセル番号
    private var tappedCellNumber: Int?
    
    // カテゴリー一覧
    var vocabularyCategories: Results<VocabularyCategory>?
    var kanjiCategories: Results<KanjiCategory>?
    
    var interstitial: GADInterstitial!
    
    // 編集用モーダル（語彙）
    @IBOutlet var coverView: UIView!
    @IBOutlet weak var modalView: UIView!
    @IBOutlet weak var modalButtonTop: UIButton!
    @IBOutlet weak var modalButtonBottom: UIButton!
    
    @IBOutlet weak var RandomButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 広告を作成し読み込む
        interstitial = createAndLoadInterstitial()
        
        // Viewの初期設定
        initView()
        
        // クイズ一覧を取得
        loadQuizCategory()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // タップしたセル番号の初期化（フラッシュカード画面から戻ってきた時に使う）
        tappedCellNumber = nil
    }
    
    // インタースティシャル広告を作成し読み込む
    func createAndLoadInterstitial() -> GADInterstitial {
        
        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
        interstitial.delegate = self
        interstitial.load(GADRequest())
        return interstitial
    }
    
    // 広告をクリックして開いた画面を閉じた直後に呼ばれる
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        
        // ⑥ 新たな広告を作成し読み込む
        interstitial = createAndLoadInterstitial()
    }
    
    func initView(){
        
        // ナビゲーションの設定
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil) // 戻るボタンのテキストを消す
        self.navigationController?.view.addSubview(self.coverView) // ナビゲーションの上にかぶせるカバー
        
        
        if self.type == 0 {
            // ボタンにテキストをセット
            modalButtonTop.setTitle("English ▶︎ Japanese", for: .normal)
            modalButtonBottom.setTitle("Japanese ▶︎ English", for: .normal)
            
            title = "Vocabulary Quizzes"
            
        } else if self.type == 1 {
            // ボタンにテキストをセット
            modalButtonTop.setTitle("Reading", for: .normal)
            modalButtonBottom.setTitle("Writing", for: .normal)
            
            title = "Kanji Quizzes"
        }
        
        // モーダル位置とサイズ
        coverView.frame = CGRect(x : 0, y : 0, width : self.view.frame.width, height : self.view.frame.height)
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
    func loadQuizCategory()  {
        let realm = try! Realm()
        
        if type == 0 {
            // 語彙
            vocabularyCategories = realm.objects(VocabularyCategory.self).sorted(byKeyPath: "order", ascending: true)
            
        } else if type == 1 {
            // 漢字
            kanjiCategories = realm.objects(KanjiCategory.self).sorted(byKeyPath: "order", ascending: true)
        }
    }
    
    // モーダルを閉じる（語彙）
    @IBAction func closeModalButtonPressed(_ sender: UIButton) {
        coverView.isHidden = true
    }
    
    // 英語 → 日本語
    @IBAction func modalButtonTopPressed(_ sender: UIButton) {
        self.quizMode = 0
        coverView.isHidden = true
        
        showInterstitialAd()
        
        // クイズ画面へ遷移
        self.performSegue(withIdentifier: "goToQuizPage", sender: nil)
    }
    
    // 日本語 →　英語
    @IBAction func modalButtonButtomPressed(_ sender: UIButton) {
        self.quizMode = 1
        coverView.isHidden = true
        
        showInterstitialAd()
        
        // クイズ画面へ遷移
        self.performSegue(withIdentifier: "goToQuizPage", sender: nil)
    }
    
    // 広告の表示準備ができていれば、表示する
    func showInterstitialAd(){
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        }
    }
    
    // ランダムボタンが押されたら
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
                
                // モーダルを表示
                self.coverView.isHidden = false
            }
        }
    }
    
    // 次の画面に渡す変数
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToQuizPage" {
            
            // 対象の画面（クイズ画面）
            let destioantionVC = segue.destination as! QuizController
            
            // クイズタイプ（語彙 or　漢字）
            destioantionVC.type = type
            
            // クイズモードを渡す
            destioantionVC.quizMode = quizMode
            
            // タップされたカテゴリーの単語一覧を渡す
            switch self.type {
            case 0:
                if tappedCellNumber != nil {
                    // 語彙
                    destioantionVC.vocabularyList = vocabularyCategories![tappedCellNumber!].items
                }else {
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
                    // 漢字
                    destioantionVC.kanjiList = kanjiCategories![tappedCellNumber!].quizModes[self.quizMode!].questions
                }else {
                    // すべての漢字を取得
                    let list = List<KanjiQuiz>()
                    for kanjiCategory in kanjiCategories! {
                        for kanjiQuizMode in kanjiCategory.quizModes {
                            for kanji in kanjiQuizMode.questions{
                                list.append(kanji)
                            }
                        }
                    }
                    destioantionVC.kanjiList = list
                }
            default:
                print("該当なし")
            }
            
        }
    }
}


extension QuizMenuController: UICollectionViewDataSource {
    
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "QuizMenuCell", for: indexPath)
        
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
extension QuizMenuController: UICollectionViewDelegate {
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
                
                // モーダルを表示
                self.coverView.isHidden = false
            }
        }
    }
}

// セルのサイズを調整する
extension QuizMenuController: UICollectionViewDelegateFlowLayout {
    
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

