//
//  FlashcardController.swift
//  JLPTN5 Study
//
//  Created by 尾野順哉 on 2020/09/16.
//  Copyright © 2020 NAOYA ONO. All rights reserved.
//

import UIKit
import RealmSwift
import Koloda
import AVFoundation
import GoogleMobileAds

class FlashcardController: UIViewController, GADInterstitialDelegate {
    
    @IBOutlet weak var kolodaView: KolodaView!
    
    // 変数
    var type: Int? // 0：語彙 1：漢字
    var category: String? // カテゴリー名
    var quizMode: Int? // 0：英語→日本語 or 読み / 1：日本語→英語 or 書き
    var vocabularyList: List<Vocabulary>?
    var kanjiList: List<Kanji>?
    var grammarType: Int? // 0：活用、1：文型パターン
    var audioPlayer: AVAudioPlayer! // 音声出力用
    var list = [[String]]() // 問題を格納するための配列
    private var cardNumber = 0 // カード番号
    private var totalCardNumber: Int? // カード数合計
    private var isFront = true // カードの表裏を管理
    
    var interstitial: GADInterstitial!
    
    @IBOutlet weak var buttonGroupView: UIView!
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var soundButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var againButton: UIButton!
    @IBOutlet weak var shuffleAndAgainButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var kolodaResultTitleView: UIView!
    @IBOutlet weak var kolodaResultButtonGroupView: UIView!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var resultLabel: UILabel!    
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var cardNumberLabel: UILabel! // カード番号（画面右上表示用）
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bannerView.adUnitID = "ca-app-pub-4166043434922569/7627970789"
        bannerView.rootViewController = self
        
        // 広告を作成し読み込む
        interstitial = createAndLoadInterstitial()
        
        navigationController?.delegate = self
        
        // フラッシュカード用のデータを生成
        createFlashCardData()
        
        // Viewの初期化
        initView()
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
    
    // インタースティシャル広告を作成し読み込む
    func createAndLoadInterstitial() -> GADInterstitial {
        
        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-4166043434922569/5616368193")
        interstitial.delegate = self
        interstitial.load(GADRequest())
        return interstitial
    }
    
    // 広告をクリックして開いた画面を閉じた直後に呼ばれる
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        
        // ⑥ 新たな広告を作成し読み込む
        interstitial = createAndLoadInterstitial()
    }
    
    // 文法データの取得
    func loadGrammarData(){
        let realm = try! Realm()
        
        if self.grammarType == 0 {
            // 活用テーブルから取得
            let conjugationList = realm.objects(Conjugation.self)
            
            // リストに値をセット
            switch self.category {
            case "nai form":
                if quizMode == 0 {
                    for conjugation in conjugationList {
                        self.list.append([conjugation.masuForm, conjugation.naiForm, "", conjugation.english])
                    }
                } else if quizMode == 1 {
                    for conjugation in conjugationList {
                        self.list.append([conjugation.jishoForm, conjugation.naiForm, "", conjugation.english])
                    }
                }
            case "masu form":
                for conjugation in conjugationList {
                    self.list.append([conjugation.jishoForm, conjugation.masuForm, "", conjugation.english])
                }
            case "dictionary form":
                for conjugation in conjugationList {
                    self.list.append([conjugation.masuForm, conjugation.jishoForm, "", conjugation.english])
                }
            case "Te form":
                if quizMode == 0 {
                    for conjugation in conjugationList {
                        self.list.append([conjugation.masuForm, conjugation.teForm, "", conjugation.english])
                    }
                } else if quizMode == 1 {
                    for conjugation in conjugationList {
                        self.list.append([conjugation.jishoForm, conjugation.teForm, "", conjugation.english])
                    }
                }
            case "Ta form":
                if quizMode == 0 {
                    for conjugation in conjugationList {
                        self.list.append([conjugation.masuForm, conjugation.taForm, "", conjugation.english])
                    }
                } else if quizMode == 1 {
                    for conjugation in conjugationList {
                        self.list.append([conjugation.jishoForm, conjugation.taForm, "", conjugation.english])
                    }
                }
            default:
                print("該当無し")
            }
        } else if self.grammarType == 1 {
            // 文型リストから抽出
            let grammarList = realm.objects(GrammarList.self)
            
            // リストに値をセット
            if quizMode == 0 {
                for grammar in grammarList {
                    self.list.append([grammar.english, grammar.japanese, ""])
                }
            } else if quizMode == 1 {
                for grammar in grammarList {
                    self.list.append([grammar.japanese, grammar.english, ""])
                }
            }
        } else if self.grammarType == 2 {
            // Countersから抽出
            let counters = realm.objects(Counters.self)
            
            // リストに値をセット
            switch self.category {
            case "People":
                if quizMode == 0 {
                    for counter in counters {
                        self.list.append([counter.english, counter.people, ""])
                    }
                } else if quizMode == 1 {
                    for counter in counters {
                        self.list.append([counter.people, counter.english, ""])
                    }
                }
            case "Small Things":
                if quizMode == 0 {
                    for counter in counters {
                        self.list.append([counter.english, counter.smallThings, ""])
                    }
                } else if quizMode == 1 {
                    for counter in counters {
                        self.list.append([counter.smallThings, counter.english, ""])
                    }
                }
            case "Flat Things":
                if quizMode == 0 {
                    for counter in counters {
                        self.list.append([counter.english, counter.flatThings, ""])
                    }
                } else if quizMode == 1 {
                    for counter in counters {
                        self.list.append([counter.flatThings, counter.english, ""])
                    }
                }
            case "Machines / Vehicles":
                if quizMode == 0 {
                    for counter in counters {
                        self.list.append([counter.english, counter.equipment, ""])
                    }
                } else if quizMode == 1 {
                    for counter in counters {
                        self.list.append([counter.equipment, counter.english, ""])
                    }
                }
            case "Long Things":
                if quizMode == 0 {
                    for counter in counters {
                        self.list.append([counter.english, counter.longOThings, ""])
                    }
                } else if quizMode == 1 {
                    for counter in counters {
                        self.list.append([counter.longOThings, counter.english, ""])
                    }
                }
            case "Age":
                if quizMode == 0 {
                    for counter in counters {
                        self.list.append([counter.english, counter.age, ""])
                    }
                } else if quizMode == 1 {
                    for counter in counters {
                        self.list.append([counter.age, counter.english, ""])
                    }
                }
            case "Minutes":
                if quizMode == 0 {
                    for counter in counters {
                        self.list.append([counter.english, counter.minutes, ""])
                    }
                } else if quizMode == 1 {
                    for counter in counters {
                        self.list.append([counter.minutes, counter.english, ""])
                    }
                }
            default:
                print("該当無し")
            }
        }
    }
    
    // 初期化
    func initView(){
                        
        // 音声ボタンを非表示に（時期バージョンで対応）
        soundButton.isHidden = true
        
        // ナビゲーションの右上にラベルをセット
        if let navigationBar = self.navigationController?.navigationBar {
            self.cardNumberLabel.frame = CGRect(x: view.frame.size.width - 70 , y: 0, width: 70.0, height: navigationBar.frame.height)
            self.cardNumberLabel.textColor = UIColor.white
            self.cardNumberLabel.textAlignment = NSTextAlignment.center
            navigationBar.addSubview(self.cardNumberLabel)
        }
        
        
        // ナビゲーションの右上にラベルをセット
//        if let navigationBar = self.navigationController?.navigationBar {
//            let labelSize = CGRect(x: view.frame.size.width - 70 , y: 0, width: 70.0, height: navigationBar.frame.height)
//
//            let label = UILabel(frame: labelSize)
//            label.textColor = UIColor.white
//            label.text = "1"
//            label.textAlignment = NSTextAlignment.center
//            navigationBar.addSubview(label)
//        }
        
        // プログレスバーの設定
        updateProgress()
        progressBar.transform = CGAffineTransform(scaleX: 1.0, y: 1.5)
        
        // ナビゲーションの設定
        self.navigationItem.title = self.category
        
        // 文法問題の場合は音声アイコンを消す
        //        if self.type == 2 {
        //            soundButton.isHidden = true
        //        }
        
        // UILabelの配列番号を確認
//        searchUILabelFromSubViews()
        
        // koloda Viewの設定
        kolodaView.dataSource = self
        kolodaView.delegate = self
        kolodaView.layer.shadowColor = UIColor.black.cgColor // 影の色
        kolodaView.layer.shadowRadius = 3.5 //　影のぼかし量
        kolodaView.layer.shadowOpacity = 0.3 //　影の透明度
        kolodaView.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        kolodaView.layer.cornerRadius = 10 // カードの角を丸める
        
        // 問題数合計
        if self.category == "Random" {
            totalCardNumber = 20
        } else {
            totalCardNumber = list.count
        }
        
        // 全体のクイズ数を算出
        updateQuizNumber()
        
        // 結果ボタンのデザイン
        self.againButton.layer.borderColor = UIColor(red: 73/255, green: 191/255, blue: 171/355, alpha: 1.0).cgColor
        self.againButton.layer.borderWidth = 1.0
        self.shuffleAndAgainButton.layer.borderColor = UIColor(red: 73/255, green: 191/255, blue: 171/355, alpha: 1.0).cgColor
        self.shuffleAndAgainButton.layer.borderWidth = 1.0
        
        // カードが最初の場合はundoボタンを非活性に
        if isFirstWord() {
            undoButton.isEnabled = false
        }
    }
    
    
    // 最初の問題かどうかをチェックする。
    func isFirstWord() -> Bool{
        if self.cardNumber == 0 {
            return true
        } else {
            return false
        }
    }
    
    // クイズ番号の更新
    func updateQuizNumber(){
        self.cardNumberLabel.text = String(cardNumber + 1) + " / " + String(totalCardNumber!)
    }
    
    
    // プログレスバーの更新
    func updateProgress(){
        if self.category == "Random" {
            progressBar.progress = Float(self.cardNumber + 1) / 20
        }else {
            progressBar.progress = Float(self.cardNumber + 1) / Float(self.list.count)
        }
    }
    
    // フラッシュカード用のデータを生成
    func createFlashCardData(){
        
        switch self.type {
        case 0: // 語彙
            if quizMode == 0 {
                // 英語 → 日本語
                for vocabulary in vocabularyList! {
                    list.append([vocabulary.english, vocabulary.japanese, vocabulary.sound])
                }
            } else if quizMode == 1 {
                // 日本語 ▶︎ 英語
                for vocabulary in vocabularyList! {
                    list.append([vocabulary.japanese, vocabulary.english, vocabulary.sound])
                }
            }
        case 1: // 漢字
            if quizMode == 0 {
                // 漢字　▶︎ ひらがな
                for kanji in kanjiList! {
                    list.append([kanji.kanji, kanji.reading, kanji.sound])
                }
            } else if quizMode == 1 {
                // ひらがな ▶︎ 漢字
                for kanji in kanjiList! {
                    list.append([kanji.reading, kanji.kanji, kanji.sound])
                }
            }
        case 2: // 文法
            loadGrammarData()
        default:
            print("該当無し")
        }
        
        // 中身をシャッフル
        list.shuffle()
    }
    
    
    @IBAction func againButtonPressed(_ sender: UIButton) {
        //色々初期化
        initCard()
        
        // 最初のカードに戻る
        kolodaView.resetCurrentCardIndex()
    }
    
    // シャッフルしてもう一度
    @IBAction func shuffleAndAgainButtonPressed(_ sender: UIButton) {
        // 色々初期化
        initCard()
        
        // カードを空にして取得し直す
        list.removeAll()
        createFlashCardData()
        
        // 広告の表示準備ができていれば、表示する
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        }
        
        // 最初のカードに戻る
        kolodaView.resetCurrentCardIndex()
    }
    
    // １つ前のページへ戻る
    @IBAction func backPageButtonPressed(_ sender: UIButton) {
        // subViewを削除（右上のUILabel）
        if let navigationBar = self.navigationController?.navigationBar {
            removeAllSubviews(parentView: navigationBar)
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    // 次のカードへ
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        kolodaView.swipe(.right)
    }
    
    //　音を鳴らす
    @IBAction func soundButtonPressed(_ sender: UIButton) {
        // 開発中
    }
    
    // 1つ前に戻る
    @IBAction func undoButtonPressed(_ sender: UIButton) {
        
        //　カード番号を-1
        self.cardNumber = self.cardNumber - 1
        
        // クイズ数を更新
        self.updateQuizNumber()
        
        // undo処理
        self.kolodaView.revertAction()
        
        // ボタンを非活性に
        nextButton.isEnabled = false
        //        soundButton.isEnabled = false
        undoButton.isEnabled = false
        
        // 1秒後にボタンを活性化
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.nextButton.isEnabled = true
            self.soundButton.isEnabled = true
            self.undoButton.isEnabled = true
            
            // 最初の問題の場合undoボタンを非活性に
            if self.isFirstWord() {
                self.undoButton.isEnabled = false
            }
        }
        
        // 問題番号を更新
        updateProgress()
        
        // カードを表側にする
        isFront = true
        
        // 最後の問題からundoをした場合に音声とnextボタンを表示
        //        if soundButton.isHidden {
        //            soundButton.isHidden = false
        //        }
        
        if nextButton.isHidden {
            nextButton.isHidden = false
        }
    }
    
    // 初期化処理
    func initCard(){
        
        self.cardNumber = 0
        updateProgress() // プログレスバーの初期化
        updateQuizNumber() // クイズ番号を初期化
        //        soundButton.isHidden = false // 音声ボタンを表示
        nextButton.isHidden = false // 次へボタンを表示
        undoButton.isEnabled = false // undoボタンを非活性に（問題１のため）
        kolodaResultTitleView.isHidden = true // 結果画面のタイトルを非表示に
        kolodaResultButtonGroupView.isHidden = true // 結果画面のボタンを非表示に
    }
    
    // SubViewの削除
    func removeAllSubviews(parentView: UIView){
        let subviews = parentView.subviews
        for subview in subviews {
            subview.removeFromSuperview()
        }
    }
}

//MARK:- KolodaViewDataSource
extension FlashcardController: KolodaViewDataSource {
    
    // 表示する件数を指定します
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        
        if self.category == "Random" {
            return 20
        } else {
            return list.count
        }
    }
    
    // カードフリック時のスピードを指定します
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .fast
    }
    
    // 指定indexで表示するViewを生成して返却します.
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        
        // CardのベースとなるView
        let cardView = UIButton()
        cardView.frame = CGRect(x: 0, y: 0, width: kolodaView.frame.width, height: kolodaView.frame.height) // カードサイズ
        cardView.layer.backgroundColor = UIColor(named: "CardBg")?.cgColor  // カードの色
        
        cardView.layer.shadowColor = UIColor.black.cgColor // 影の色
        cardView.layer.shadowRadius = 3.5 //　影のぼかし量
        cardView.layer.shadowOpacity = 0.3 //　影の透明度
        cardView.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        cardView.layer.cornerRadius = 10 // カードの角を丸める
        
        // カードのテキストの装飾
        cardView.setTitleColor(UIColor(named: "textColorBase"), for: .normal) // フォントカラー
        
        // テキストが長い場合は複数行に
        cardView.titleLabel!.numberOfLines = 3
        cardView.titleLabel?.adjustsFontSizeToFitWidth = true // フォントサイズの自動調整
        
        //　「文法」かつ「動詞の活用の場合」
        if grammarType == 0, type == 2 {
            cardView.titleLabel?.font = UIFont(name: "Quicksand-Bold", size: 28) // カスタムフォント
            cardView.setTitle(list[index][0] + "\n" + list[index][3] , for: .normal) // 改行して下に英訳を追加
            cardView.titleLabel?.textAlignment = NSTextAlignment.center // 中央寄せ

        } else {
            cardView.titleLabel?.font = UIFont(name: "Quicksand-Bold", size: 32) // カスタムフォント
            cardView.setTitle(list[index][0], for: .normal) // カードの表にテキストをセット
        }
                        
        // タップされたときのaction（flip）
        cardView.addTarget(self,
                           action: #selector(flip( _:)),
                           for: .touchUpInside)
        
        return cardView
    }
    
    // カードがタップされたら裏返す
    @objc func flip(_ sender : Any){
        
        // 現在のカードが表なら
        if isFront {
            isFront = false
            
            // カード裏の値をセットする
            (sender as AnyObject).setTitle(self.list[kolodaView.currentCardIndex][1], for: .normal)
            
            // ひっくり返すアニメーション
            UIView.transition(with: sender as! UIView, duration: 0.4, options: .transitionFlipFromLeft, animations: nil, completion: nil)
        } else { //　カードが裏なら
            isFront = true
            
            //　「文法」かつ「動詞の活用の場合」
            if grammarType == 0, type == 2 {
                (sender as AnyObject).setTitle(self.list[kolodaView.currentCardIndex][0] + "\n" + list[kolodaView.currentCardIndex][3], for: .normal)

            } else {
                (sender as AnyObject).setTitle(self.list[kolodaView.currentCardIndex][0], for: .normal)
            }
                        
            // ひっくり返すアニメーション
            UIView.transition(with: sender as! UIView, duration: 0.4, options: .transitionFlipFromRight, animations: nil, completion: nil)
        }
    }
}

//MARK:- KolodaViewDelegate
extension FlashcardController: KolodaViewDelegate {
    
    // フリックできる方向を指定する
    func koloda(_ koloda: KolodaView, allowedDirectionsForIndex index: Int) -> [SwipeResultDirection] {
        return [.left, .right]
    }
    
    //カードがスワイプされたときの処理
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        
        // 次のカード番号をセット
        cardNumber = index + 1
        
        // カードを表側にする（次のカードを表にするため）
        isFront = true
        
        //プログレスバーの更新
        updateProgress()
        
        //最後の問題でなければ、 クイズ数を更新
        if cardNumber != totalCardNumber! {
            self.updateQuizNumber()
        }
        
        // undoボタンを活性化
        if undoButton.isEnabled == false {
            undoButton.isEnabled = true
        }
    }
    
    // カードを全て消費したときの処理を定義する
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        // 結果ラベルに値をセット
        resultLabel.text = "You learned " + String(totalCardNumber!) + " words"
        
        // 音声、次へボタンを非表示に
        soundButton.isHidden = true
        nextButton.isHidden = true
        
        // 結果テキストと次の操作ボタンを表示
        kolodaResultTitleView.isHidden = false
        kolodaResultButtonGroupView.isHidden = false
        
    }
    
    func kolodaShouldTransparentizeNextCard(_ koloda: KolodaView) -> Bool {
        return true
    }
}

//MARK:- AVAudioPlayerDelegate
extension FlashcardController: AVAudioPlayerDelegate {
    
    // 音を鳴らす処理
    func playSound(name: String){
        // 音声ファイルの取得
        guard let soundFile = NSDataAsset(name: name) else {
            print("音源ファイルが見つかりません1")
            return
        }
        
        // 音を鳴らす
        audioPlayer = try! AVAudioPlayer(data:soundFile.data, fileTypeHint:"mp3")
        audioPlayer!.play()
    }
}

// ナビゲーションバーの戻るボタンを押した時の処理
extension FlashcardController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController is FlashCardMenuController, let navigationBar = self.navigationController?.navigationBar {
            removeAllSubviews(parentView: navigationBar)
        }
    }
}
