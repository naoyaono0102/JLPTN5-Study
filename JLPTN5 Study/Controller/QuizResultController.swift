//
//  QuizResultController.swift
//  JLPTN5 Study
//
//  Created by 尾野順哉 on 2020/09/15.
//  Copyright © 2020 NAOYA ONO. All rights reserved.
//

import UIKit
import AVFoundation
import GoogleMobileAds

class QuizResultController: UIViewController, GADInterstitialDelegate {
    
    var correctCount = 0
    var questions = [String]()
    var answers = [String]()
    var sounds = [String]()
    var results = [Int]() // 正誤の結果を格納（0：正解 / 1:不正解）
    var audioPlayer: AVAudioPlayer! // 音声出力用
    var quizType: Int = 0 // MockExamページからの場合は１にする
    var userChoices = [String]()  // ユーザーが選んだ答え
    var numberOfQuestions: Int = 0 // 問題数
    
    var interstitial: GADInterstitial!
    
    @IBOutlet weak var messageLabel: UILabel!    
    @IBOutlet weak var againButton: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    // テスト
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var innerView: UIView!
    
    // セルのレイアウト設定
    private let sectionInsets = UIEdgeInsets(top: 15, left: 15, bottom: 0, right: 15)
    // 1行あたりのアイテム数
    private var itemsPerRow: CGFloat = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 広告を作成し読み込む
        interstitial = createAndLoadInterstitial()
        // ボタンの初期設定
        initButton()
        
        // スコアをセット
        setScore()
        
    }
    
    // ナビゲーション非表示
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    // scrollViewの高さを動的に変更する
    override func viewDidLayoutSubviews() {
        if questions.count == 10 {
            innerView.frame.size.height = 1800
            scrollView.contentSize = CGSize(width: scrollView.frame.width , height: innerView.frame.size.height)
        }else if questions.count < 10 {
            innerView.frame.size.height = 1100
            scrollView.contentSize = CGSize(width: scrollView.frame.width , height: innerView.frame.size.height)
        }
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
    
    // ボタンの初期化
    func initButton(){
        // ボタンの影
        self.againButton.layer.shadowColor = UIColor.black.cgColor //　影の色
        self.againButton.layer.shadowOpacity = 0.2  //影の濃さ
        self.againButton.layer.shadowRadius = 2.0 // 影のぼかし量
        self.againButton.layer.shadowOffset = CGSize(width: 2.0, height: 2.0) // 影の方向
        
        
        self.backButton.layer.shadowColor = UIColor.black.cgColor //　影の色
        self.backButton.layer.shadowOpacity = 0.2  //影の濃さ
        self.backButton.layer.shadowRadius = 2.0 // 影のぼかし量
        self.backButton.layer.shadowOffset = CGSize(width: 2.0, height: 2.0) // 影の方向
    }
    
    // スコアをセット
    func setScore() {
        // 成績をセット
        scoreLabel.text =  String(correctCount) + " / " + String(numberOfQuestions)
        
        let score = Int(Float(correctCount)/Float(numberOfQuestions) * 10)
        print(score)
        // スコア判定
        if quizType == 0 {
            switch score {
            case (0...3):
                messageLabel.text = "もっとがんばろう!"
                messageLabel.font = UIFont(name: "Quicksand-Bold", size: 17)
                messageLabel.textColor = UIColor(red: 242/255, green: 130/255, blue: 130/255, alpha: 1.0)
            case (4...6):
                messageLabel.text = "もうすこしがんばろう"
            case (7...9):
                messageLabel.text = "よくできました!"
            case 10:
                messageLabel.text = "パーフェクト!"
            default:
                print("Error")
            }
        }else {
            if score >= 7 {
                print("合格")
                messageLabel.text = "Pass!"
                messageLabel.font = UIFont(name: "Quicksand-Bold", size: 20)
                messageLabel.textColor = UIColor(red: 73/255, green: 191/255, blue: 171/255, alpha: 1.0)
                
            } else {
                print("不合格")
                messageLabel.text = "Fail!"
                messageLabel.font = UIFont(name: "Quicksand-Bold", size: 20)
                messageLabel.textColor = UIColor(red: 242/255, green: 130/255, blue: 130/255, alpha: 1.0)
            }
        }
        
    }
    
    @IBAction func againButtonPressed(_ sender: UIButton) {
        // 広告の表示準備ができていれば、表示する
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        }
        
        // 前の画面へ
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        print("メニュー画面へ")
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.popToViewController(navigationController!.viewControllers[1], animated: true)
    }
}

extension QuizResultController: UICollectionViewDataSource {
    
    // セル数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return questions.count
    }
    
    // セルに値をセット
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // widthReuseIdentifierにはStoryboardで設定したセルのIDを指定
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ResultCell", for: indexPath)
        
        // セルのラベルに値をセット
        let questionTitle = cell.contentView.viewWithTag(2) as! UILabel
        let answerTitle = cell.contentView.viewWithTag(3) as! UILabel
        let resultLabel = cell.contentView.viewWithTag(4) as! UILabel
        let speakerView = cell.contentView.viewWithTag(5)!
        let userAnserTitle = cell.contentView.viewWithTag(6) as! UILabel
        
        
        //        if quizType == 1 {
        //            speakerView.isHidden = true
        //        }
        
        // 音声アイコン非表示
        speakerView.isHidden = true
        
        questionTitle.text = "Q. " + questions[indexPath.row]
        answerTitle.text = "A. " + answers[indexPath.row]
        userAnserTitle.text = "Your choice. " + userChoices[indexPath.row]
        
        // 結果
        if results[indexPath.row] == 0 {
            print("正解")
            resultLabel.text = "Good"
            resultLabel.textColor = UIColor(red: 123/255, green: 192/255, blue: 120/255, alpha: 1)
            
        } else if results[indexPath.row] == 1 {
            resultLabel.text = "Bad"
            resultLabel.textColor = UIColor(red: 241/255, green: 130/255, blue: 130/255, alpha: 1.0)
        }
        
        // ラベルのサイズ調整
        questionTitle.adjustsFontSizeToFitWidth = true
        answerTitle.adjustsFontSizeToFitWidth = true
        userAnserTitle.adjustsFontSizeToFitWidth = true
        
        // セルのデザイン
        cell.layer.cornerRadius = 10
        cell.backgroundColor = UIColor(named: "MenuButtonColor")
        cell.layer.masksToBounds = false // 溢れる分を表示
        cell.layer.shadowColor = UIColor.black.cgColor //　影の色
        cell.layer.shadowOpacity = 0.3  //影の濃さ
        cell.layer.shadowRadius = 2.0 // 影のぼかし量
        cell.layer.shadowOffset = CGSize(width: 1.0, height: 1.0) // 影の方向
        
        return cell
    }
}

// セルをタップしたときの処理
extension QuizResultController: UICollectionViewDelegate {
    // セルがタップされた時の処理（次のバージョンで対応）
    //    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    //
    //        if quizType == 0 {
    //
    //            let cell = collectionView.cellForItem(at: indexPath)
    //
    //            // セルの拡大・縮小のアニメーション
    //            UIView.animate(
    //                // セルを縮小する
    //                withDuration: 0.1,
    //                delay: 0,
    //                options: [.curveEaseOut],
    //                animations: {
    //                    cell!.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
    //            })
    //            { finished in
    //                // セルを拡大する
    //                UIView.animate(
    //                    withDuration: 0.1,
    //                    delay: 0,
    //                    options: [.curveEaseIn],
    //                    animations: {
    //                        cell!.transform = CGAffineTransform.identity
    //                }) { finished in
    //
    //                    // 音を鳴らす
    //                    self.soundPlay(self.sounds[indexPath.row])
    //                }
    //            }
    //        }
    //    }
    
    func soundPlay(_ name: String) {
        
        print(name)
        
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
extension QuizResultController: UICollectionViewDelegateFlowLayout {
    
    // Screenサイズに応じたセルサイズを返す
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: 120)
    }
    
    // 周囲の余白
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    // セルの行間の設定
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20.0
    }
}

