//
//  QuizController.swift
//  JLPTN5 Study
//
//  Created by 尾野順哉 on 2020/09/14.
//  Copyright © 2020 NAOYA ONO. All rights reserved.
//

import UIKit
import RealmSwift
import AVFoundation
import GoogleMobileAds

class QuizController: UIViewController {
    
    // UI部品
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerButtonA: UIButton!
    @IBOutlet weak var answerButtonB: UIButton!
    @IBOutlet weak var answerButtonC: UIButton!
    @IBOutlet weak var answerButtonD: UIButton!
    
    @IBOutlet weak var timeLimitBar: UIProgressView!
    @IBOutlet weak var soundButton: UIButton!
    @IBOutlet weak var timeLimitToggle: UIBarButtonItem!
    @IBOutlet weak var resultImage: UIImageView!
    
    @IBOutlet weak var bannerView: GADBannerView!
    
    //前の画面から受け取る値
    var type: Int? // 0：語彙 1：漢字
    var quizMode: Int? // 0：英語→日本語 or 読み / 1：日本語→英語 or 書き
    var vocabularyList: List<Vocabulary>?
    //    var kanjiList: List<Kanji>?
    
    var kanjiList: List<KanjiQuiz>?
    
    // 変数
    var list = [[String]]() // 一時的に格納するために使用
    var questions = [String]() // 問題
    var answers = [String]() // 答え
    var sounds = [String]() // 音声
    var choices = [[String]]() // 選択肢
    var userChoices = [String]()  // ユーザーが選んだ答え
    var results = [Int]() // 正誤の結果を格納（0：正解 / 1:不正解）
    var maxQuizNum = 0
    
    var questionNumber = 0 // 問題番号
    var correctCount = 0 // 正解数
    var timer: Timer? // タイムリミット
    var audioPlayer: AVAudioPlayer! // 音声出力用
    private var isTimerAcctive: Bool = true // タイマーのON / OFF
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        
        
        navigationController?.delegate = self
        
        initButton()
        
        // タイムリミットバーを太くする
        timeLimitBar.transform = CGAffineTransform(scaleX: 1.0, y: 3.0)
    }
    
    // ボタンの初期設定
    func initButton(){
        
        // 音声アイコンを非表示に
        soundButton.isHidden = true
        
        // 影をつける
        answerButtonA.layer.shadowColor = UIColor.black.cgColor //　影の色
        answerButtonA.layer.shadowOpacity = 0.2  //影の濃さ
        answerButtonA.layer.shadowRadius = 3.0 // 影のぼかし量
        answerButtonA.layer.shadowOffset = CGSize(width: 1.5, height: 1.5) // 影の方向
        
        answerButtonB.layer.shadowColor = UIColor.black.cgColor
        answerButtonB.layer.shadowOpacity = 0.2
        answerButtonB.layer.shadowRadius = 3.0
        answerButtonB.layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
        
        answerButtonC.layer.shadowColor = UIColor.black.cgColor
        answerButtonC.layer.shadowOpacity = 0.2
        answerButtonC.layer.shadowRadius = 3.0
        answerButtonC.layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
        
        answerButtonD.layer.shadowColor = UIColor.black.cgColor
        answerButtonD.layer.shadowOpacity = 0.2
        answerButtonD.layer.shadowRadius = 3.0
        answerButtonD.layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 枠から文字が飛び出さないように
        questionLabel.adjustsFontSizeToFitWidth = true
        answerButtonA.titleLabel?.adjustsFontSizeToFitWidth = true
        answerButtonB.titleLabel?.adjustsFontSizeToFitWidth = true
        answerButtonC.titleLabel?.adjustsFontSizeToFitWidth = true
        answerButtonD.titleLabel?.adjustsFontSizeToFitWidth = true
        
        // 英語 ▶︎ 日本語 / Readingテストなら音声ボタンを非表示にする
        if quizMode == 0 {
            soundButton.isEnabled = false
            soundButton.isHidden = true
        }
        
        // クイズの問題を取得する
        createQuiz()
        
        // クイズをセット
        setQuiz()
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
    
    // タイマー更新
    func updateTimeLimit() {
        // 0.1秒毎に進捗を1%減らす
        self.timer = Timer.scheduledTimer(timeInterval: 0.01, target:self, selector:#selector(minusTime), userInfo: nil, repeats: true)
    }
    
    // 時間を少しずつマイナスしていく
    @objc func minusTime(){
        // プログレスバーを更新
        timeLimitBar.progress -= 0.001
        
        // 時間が0になったら
        if timeLimitBar.progress == 0.0 {
            self.timer?.invalidate() // タイマー停止
            
            self.userChoices.append("")
            
            // 不正解の画像を表示
            resultImage.isHidden = false
            resultImage.image =  UIImage(named: "wrong-icon")
            
            // 結果に不正解を追加
            self.results.append(1)
            
            // 不正解の音を鳴らす
            playSound(name: "incorrect_sound")
            
            // 正解に色をつけ、それ以外を非表示に
            if answers[questionNumber] == answerButtonA.currentTitle! {
                answerButtonA.backgroundColor = UIColor(red: 123/255, green: 192/255, blue: 120/255, alpha: 1)
                answerButtonA.isEnabled = false
                answerButtonA.setTitleColor(UIColor.white, for: .normal)
            } else {
                answerButtonA.isHidden = true
            }
            
            if answers[questionNumber] == answerButtonB.currentTitle! {
                answerButtonB.backgroundColor = UIColor(red: 123/255, green: 192/255, blue: 120/255, alpha: 1)
                answerButtonB.isEnabled = false
                answerButtonB.setTitleColor(UIColor.white, for: .normal)
            } else {
                answerButtonB.isHidden = true
            }
            
            if answers[questionNumber] == answerButtonC.currentTitle! {
                answerButtonC.backgroundColor = UIColor(red: 123/255, green: 192/255, blue: 120/255, alpha: 1)
                answerButtonC.isEnabled = false
                answerButtonC.setTitleColor(UIColor.white, for: .normal)
            } else {
                answerButtonC.isHidden = true
            }
            
            if answers[questionNumber] == answerButtonD.currentTitle! {
                answerButtonD.backgroundColor = UIColor(red: 123/255, green: 192/255, blue: 120/255, alpha: 1)
                answerButtonD.isEnabled = false
                answerButtonD.setTitleColor(UIColor.white, for: .normal)
            } else {
                answerButtonD.isHidden = true
            }
            
            
            // クイズが終わったかどうかチェック
            if isFinish() {
                // 結果ページへ移動
                Timer.scheduledTimer(timeInterval: 1.0, target:self, selector:#selector(moveResultPage), userInfo: nil, repeats: false)
            }else {
                // 問題ナンバーを+1し、問題を更新
                questionNumber += 1
                Timer.scheduledTimer(timeInterval: 1.0, target:self, selector:#selector(setQuiz), userInfo: nil, repeats: false)
            }
            
        }
    }
    
    @IBAction func timerOnOffButtonPressde(_ sender: UIBarButtonItem) {
        if self.isTimerAcctive {
            // タイマー停止
            self.timer?.invalidate()
            self.isTimerAcctive = false
            self.timeLimitToggle.image = UIImage(named: "play-icon")
            
        }else {
            // タイマー起動
            updateTimeLimit()
            self.isTimerAcctive = true
            self.timeLimitToggle.image = UIImage(named: "stop-icon")
        }
    }
    
    
    // クイズ問題を生成する
    func createQuiz(){
        maxQuizNum = 10
        
        if type == 0 {
            for vocabulary in vocabularyList! {
                list.append([vocabulary.english, vocabulary.japanese, vocabulary.sound])
            }
            
            //　問題を１０問作成
            for i in 0..<10 {
                // 単語一覧からランダムに４問取得
                let quizList = list.choose(4)
                
                // クイズモードをチェック
                if quizMode == 0 {
                    // 配列の先頭を答えにする
                    questions.append(quizList[0][0]) // 問題（英語）
                    answers.append(quizList[0][1]) // 答え（日本語）
                    sounds.append(quizList[0][2]) // 問題の音声（日本語）
                    choices.append([quizList[0][1], quizList[1][1], quizList[2][1], quizList[3][1]]) //選択肢 (日本語)
                    
                    choices[i].shuffle() // 選択肢をシャッフルする
                }
                    
                else if quizMode == 1 {
                    // 配列の先頭を答えにする
                    questions.append(quizList[0][1]) // 問題（日本語）
                    answers.append(quizList[0][0]) // 答え（英語）
                    sounds.append(quizList[0][2]) // 問題の音声
                    choices.append([quizList[0][0], quizList[1][0], quizList[2][0], quizList[3][0]]) //選択肢 （英語）
                    choices[i].shuffle() // 選択肢をシャッフルする
                }
                else {
                    print("不正な処理")
                    return
                }
            }
        } else if type == 1 {
            // 配列に問題集を対比
            var KanjiQuizList = [KanjiQuiz]()
            for kanjiQuiz in kanjiList! {
                KanjiQuizList.append(kanjiQuiz)
            }
            
            // 漢字リストをシャッフル
            KanjiQuizList.shuffle()
            
            if KanjiQuizList.count >= 10 {
                maxQuizNum = 10
            } else {
                maxQuizNum = KanjiQuizList.count
            }
            
            // 出題する問題を作成する（max 10問）
            for i in 0..<maxQuizNum {
                // シャッフル済みのリストから１問取得
                let quiz = KanjiQuizList[i]
                
                questions.append(quiz.question) // 問題
                answers.append(quiz.answer) // 答え
                choices.append([quiz.answer, quiz.wrong1, quiz.wrong2, quiz.wrong3]) //選択肢
                
                //選択肢をシャッフル
                choices[i].shuffle() // 選択肢をシャッフルする
            }
        }
    }
    
    // クイズ問題を画面にセットする
    @objc func setQuiz(){
        // ナビゲーションタイトルに問題番号をセット
        title = String(questionNumber + 1) + " / " + String(maxQuizNum)
        
        // 正解・不正解の画像を隠す
        resultImage.isHidden = true
        
        // タイムリミットを初期化
        timeLimitBar.progress = 1.0
        
        // ボタンを表示する
        answerButtonA.isHidden = false
        answerButtonB.isHidden = false
        answerButtonC.isHidden = false
        answerButtonD.isHidden = false
        
        // ボタンを有効にする
        answerButtonA.isEnabled = true
        answerButtonB.isEnabled = true
        answerButtonC.isEnabled = true
        answerButtonD.isEnabled = true
        
        // ボタンのテキストカラー
        answerButtonA.setTitleColor(UIColor(named: "quizButtonTextColor"), for: .normal)
        answerButtonB.setTitleColor(UIColor(named: "quizButtonTextColor"), for: .normal)
        answerButtonC.setTitleColor(UIColor(named: "quizButtonTextColor"), for: .normal)
        answerButtonD.setTitleColor(UIColor(named: "quizButtonTextColor"), for: .normal)
        
        
        // ボタンの色を設定する
        answerButtonA.backgroundColor = UIColor(named: "quizButtonColor")
        answerButtonB.backgroundColor = UIColor(named: "quizButtonColor")
        answerButtonC.backgroundColor = UIColor(named: "quizButtonColor")
        answerButtonD.backgroundColor = UIColor(named: "quizButtonColor")
        
        // 英語 ▶︎ 日本語
        questionLabel.text = questions[questionNumber]
        
        // 選択肢をセット
        answerButtonA.setTitle(choices[questionNumber][0], for:.normal)
        answerButtonB.setTitle(choices[questionNumber][1], for:.normal)
        answerButtonC.setTitle(choices[questionNumber][2], for:.normal)
        answerButtonD.setTitle(choices[questionNumber][3], for:.normal)
        
        // カウントダウンスタート
        if isTimerAcctive {
            updateTimeLimit()
        }
    }
    
    // 選択肢がタップされた時の処理
    @IBAction func answerButtonPressed(_ sender: UIButton) {
        // タイマーを停止
        self.timer?.invalidate()
        
        // ユーザーの選択した答え
        let userAnswer = sender.currentTitle!
        self.userChoices.append(userAnswer)
        
        // 正解の場合
        if userAnswer == answers[questionNumber]{
            playSound(name: "correct_sound")
            
            // 正解画像を表示
            resultImage.isHidden = false
            resultImage.image =  UIImage(named: "correct-icon")
            
            // 結果に正解を追加
            self.results.append(0)
            correctCount += 1
            
            // 正解したボタンを緑に、テキストを白に
            sender.backgroundColor = UIColor(red: 123/255, green: 192/255, blue: 120/255, alpha: 1)
            sender.setTitleColor(UIColor.white, for: .normal)
            
            
            // 不正解のボタンを非表示にする
            if userAnswer != answerButtonA.currentTitle! {
                answerButtonA.isHidden = true
            } else {
                answerButtonA.isEnabled = false
            }
            
            if userAnswer != answerButtonB.currentTitle! {
                answerButtonB.isHidden = true
            } else {
                answerButtonB.isEnabled = false
            }
            
            if userAnswer != answerButtonC.currentTitle! {
                answerButtonC.isHidden = true
            } else {
                answerButtonC.isEnabled = false
            }
            
            if userAnswer != answerButtonD.currentTitle! {
                answerButtonD.isHidden = true
            } else {
                answerButtonD.isEnabled = false
            }
            
        } else {
            playSound(name: "incorrect_sound")
            
            // 不正解の画像を表示
            resultImage.isHidden = false
            resultImage.image =  UIImage(named: "wrong-icon")
            
            // 結果に不正解を追加
            self.results.append(1)
            
            // 不正解のボタンの色を赤に、テキストを白に
            sender.backgroundColor = UIColor(red: 213/255, green: 73/255, blue: 76/255, alpha: 1)
            sender.setTitleColor(UIColor.white, for: .normal)
            
            // ボタンを全て非活性にする
            answerButtonA.isEnabled = false
            answerButtonB.isEnabled = false
            answerButtonC.isEnabled = false
            answerButtonD.isEnabled = false
            
            // 正解のボタンの色を緑で示す。それ以外のボタンは非表示にする。
            if answers[questionNumber] == answerButtonA.currentTitle! {
                // 選択肢Aが正解。ボタンを緑色に、テキストを白に
                answerButtonA.backgroundColor = UIColor(red: 123/255, green: 192/255, blue: 120/255, alpha: 1)
                answerButtonA.setTitleColor(UIColor.white, for: .normal)
            } else if userAnswer != answerButtonA.currentTitle! {
                // もし、ユーザーが選んだものがAでなければボタンを非表示にする
                answerButtonA.isHidden = true
            }
            
            if answers[questionNumber] == answerButtonB.currentTitle! {
                answerButtonB.backgroundColor = UIColor(red: 123/255, green: 192/255, blue: 120/255, alpha: 1)
                answerButtonB.setTitleColor(UIColor.white, for: .normal)
            } else if userAnswer != answerButtonB.currentTitle! {
                answerButtonB.isHidden = true
            }
            
            if answers[questionNumber] == answerButtonC.currentTitle! {
                answerButtonC.backgroundColor = UIColor(red: 123/255, green: 192/255, blue: 120/255, alpha: 1)
                answerButtonC.setTitleColor(UIColor.white, for: .normal)
            } else if userAnswer != answerButtonC.currentTitle! {
                answerButtonC.isHidden = true
            }
            
            if answers[questionNumber] == answerButtonD.currentTitle! {
                answerButtonD.backgroundColor = UIColor(red: 123/255, green: 192/255, blue: 120/255, alpha: 1)
                answerButtonD.setTitleColor(UIColor.white, for: .normal)
            } else if userAnswer != answerButtonD.currentTitle! {
                answerButtonD.isHidden = true
            }
        }
        
        // クイズが終わったかどうかチェック
        if isFinish() {
            // 結果ページへ移動
            Timer.scheduledTimer(timeInterval: 1.0, target:self, selector:#selector(moveResultPage), userInfo: nil, repeats: false)
        }else {
            // 問題ナンバーを+1し、問題を更新
            questionNumber += 1
            Timer.scheduledTimer(timeInterval: 1.0, target:self, selector:#selector(setQuiz), userInfo: nil, repeats: false)
        }
        
    }
    
    // クイズが全問終わったかどうかチェック
    func isFinish() -> Bool{
        if questionNumber + 1 < questions.count{
            return false
        } else {
            return true
        }
    }
    
    
    @IBAction func soundButtonPressed(_ sender: UIButton) {
        playSound(name: sounds[questionNumber])
    }
    
    // 結果ページへ移動
    @objc func moveResultPage(){
        performSegue(withIdentifier: "goToQuizResultPage",sender: nil)
    }
    
    // 結果画面に渡す変数
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToQuizResultPage" {
            
            // 対象の画面（クイズ画面）
            let destioantionVC = segue.destination as! QuizResultController
            
            // クイズ問題
            destioantionVC.questions = self.questions
            
            // 答え
            destioantionVC.answers = self.answers
            
            // ユーザーが選択した答え
            destioantionVC.userChoices = self.userChoices
            
            // 音声
            destioantionVC.sounds = self.sounds
            
            // 正誤表
            destioantionVC.results = self.results
            
            // 正解数
            destioantionVC.correctCount = correctCount
            
            // 問題数
            destioantionVC.numberOfQuestions = questions.count
            
            // 変数を初期化
            correctCount = 0
            questionNumber = 0
            list.removeAll()
            questions.removeAll()
            answers.removeAll()
            sounds.removeAll()
            choices.removeAll()
            results.removeAll()
            userChoices.removeAll()
        }
    }
    
    
    //    // 前の画面に戻る
    //    @IBAction func backButtonPressed(_ sender: UIButton) {
    //
    //        // タイマーを停止
    //        //        self.timer?.invalidate()
    //
    //        // トップ画面に戻る
    //        self.navigationController?.popViewController(animated: true)
    //    }
}

// シャッフルして、先頭からnの数だけ取得
extension Collection {
    func choose(_ n: Int) -> ArraySlice<Element> {
        shuffled().prefix(n)
    }
}

//MARK:- AVAudioPlayerDelegate
extension QuizController: AVAudioPlayerDelegate {
    
    // 音を鳴らす処理
    func playSound(name: String){
        // 音声ファイルの取得
        guard let soundFile = NSDataAsset(name: name) else {
            print("音源ファイルが見つかりません1")
            return
        }
        
        // 音を鳴らす
        audioPlayer = try! AVAudioPlayer(data:soundFile.data,fileTypeHint:"mp3")
        audioPlayer!.play()
    }
}

// ナビゲーションバーの戻るボタンを押した時の処理
extension QuizController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController is QuizMenuController {
            // タイマーを停止
            self.timer?.invalidate()
        }
    }
}
