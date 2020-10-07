//
//  MockExamController.swift
//  JLPTN5 Study
//
//  Created by 尾野順哉 on 2020/09/22.
//  Copyright © 2020 NAOYA ONO. All rights reserved.
//

import UIKit
import RealmSwift
import AVFoundation
import GoogleMobileAds

class MockExamController: UIViewController {
    
    // タイムリミットと問題数
    // 語彙
    // -- part1：20問 / 20秒
    // -- part2：10問 / 1分
    // 漢字
    // -- part1：20問 / 20秒
    // -- part2：20問 / 20秒
    // 文法
    // -- part1：20問 / 20秒
    // -- part2：5問 / 1分
    
    //前の画面から受け取る値
    var type: Int? // クイズの種類（語彙 or 漢字）
    var part: Int? // part（1 or 2）
    
    // UI部品
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerButtonA: UIButton!
    @IBOutlet weak var answerButtonB: UIButton!
    @IBOutlet weak var answerButtonC: UIButton!
    @IBOutlet weak var answerButtonD: UIButton!
    @IBOutlet weak var timeLimitBar: UIProgressView!
    @IBOutlet weak var timeLimitToggle: UIBarButtonItem!
    @IBOutlet weak var resultImage: UIImageView!
    @IBOutlet weak var bannerView: GADBannerView!
    
    // 変数
    var list = [[String]]() // 一時的に格納するために使用
    var questions = [String]() // 問題
    var answers = [String]() // 答え
    var choices = [[String]]() // 選択肢
    var results = [Int]() // 正誤の結果を格納（0：正解 / 1:不正解）
    
    var questionNumber = 0 // 問題番号
    var correctCount = 0 // 正解数
    var timer: Timer? // タイムリミット
    var audioPlayer: AVAudioPlayer! // 音声出力用
    private var isTimerAcctive: Bool = true // タイマーのON / OFF
    var userChoices = [String]()  // ユーザーが選んだ答え
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        
        navigationController?.delegate = self
        
        // タイムリミットバーを太くする
        timeLimitBar.transform = CGAffineTransform(scaleX: 1.0, y: 3.0)
        
        initButton()        
    }
    
    func initButton() {
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
    
    func createQuiz() {
        let realm = try! Realm()
        
        // 問題を抽出
        if type == 0 {
            // 語彙
            let vocabularyQuizPart = realm.objects(VocabularyMockCategory.self).filter("part = \(self.part!)").first
            
            var vocabularyQuizList = [VocabularyMock]()
            for vocabularyQuiz in vocabularyQuizPart!.items {
                vocabularyQuizList.append(vocabularyQuiz)
            }
            
            // 語彙リストをシャッフル
            vocabularyQuizList.shuffle()
            
            // 抽出する問題数
            var questionTotalNumber = 0
            if part == 1 {
                questionTotalNumber = 20
            } else if part == 2 {
                questionTotalNumber = 10
            }
            
            // 出題する問題を作成する（part1：20 / part2:10）
            //            for i in 0..<10 {
            for i in 0..<questionTotalNumber {
                // シャッフル済みのリストから１問取得
                let quiz = vocabularyQuizList[i]
                
                questions.append(quiz.question) // 問題
                answers.append(quiz.answer) // 答え
                choices.append([quiz.answer, quiz.wrong1, quiz.wrong2, quiz.wrong3]) //選択肢
                
                //選択肢をシャッフル
                choices[i].shuffle() // 選択肢をシャッフルする
            }
        } else if type == 1 {
            // 漢字テストを抽出
            let kanjiQuizPart = realm.objects(KanjiMockCategory.self).filter("part = \(self.part!)").first
            
            var KanjiQuizList = [KanjiMock]()
            for kanjiQuiz in kanjiQuizPart!.items {
                KanjiQuizList.append(kanjiQuiz)
            }
            
            // 漢字リストをシャッフル
            KanjiQuizList.shuffle()
            
            // 出題する問題を作成する（20問）
            for i in 0..<20 {
                
                // シャッフル済みのリストから１問取得
                let quiz = KanjiQuizList[i]
                
                questions.append(quiz.question) // 問題
                answers.append(quiz.answer) // 答え
                choices.append([quiz.answer, quiz.wrong1, quiz.wrong2, quiz.wrong3]) //選択肢
                
                //選択肢をシャッフル
                choices[i].shuffle() // 選択肢をシャッフルする
            }
        } else if type == 2 {
            // 語彙
            let grammarQuizPart = realm.objects(GrammarMockCategory.self).filter("part = \(self.part!)").first
            
            var grammarQuizList = [GrammarMock]()
            for grammarQuiz in grammarQuizPart!.items {
                grammarQuizList.append(grammarQuiz)
            }
            
            // 文法問題リストをシャッフル
            grammarQuizList.shuffle()
            
            // 抽出する問題数
            var questionTotalNumber = 0
            if part == 1 {
                questionTotalNumber = 20
            } else if part == 2 {
                questionTotalNumber = 5
            }
            
            // 出題する問題を作成する（part1：20 / part2:5）
            for i in 0..<questionTotalNumber {
                
                // シャッフル済みのリストから１問取得
                let quiz = grammarQuizList[i]
                
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
        title = String(questionNumber + 1) + " / " + String(questions.count)
        
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
        
        
        // 問題をセット
        questionLabel.attributedText = NSAttributedString(string: questions[questionNumber], lineSpacing: 15.0, alignment: .left)
        
        
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
    
    // タイマー更新
    func updateTimeLimit() {
        // 0.1秒毎に進捗を1%減らす
        self.timer = Timer.scheduledTimer(timeInterval: 0.01, target:self, selector:#selector(minusTime), userInfo: nil, repeats: true)
    }
    
    // 時間を少しずつマイナスしていく
    @objc func minusTime(){
        // プログレスバーを更新
        
        if self.type == 0 {
            // 語彙
            if self.part == 1 {
                timeLimitBar.progress -= 0.0005 // 20秒(1/2000)
            } else {
                timeLimitBar.progress -= 1/4000 // 40秒(1/4000)
            }
        } else if self.type == 1 {
            // 漢字
            timeLimitBar.progress -= 0.0005 // 20秒(1/2000)
        } else if self.type == 2 {
            // 文法
            if self.part == 1 {
                timeLimitBar.progress -= 0.0005 // 20秒(1/2000)
            } else {
                timeLimitBar.progress -= 1/4000 // 40秒(1/4000)
            }
        }
        //        timeLimitBar.progress -= 0.001 // 10秒(1/1000)
        
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
    
    // 答えをチェック
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
    
    // 結果ページへ移動
    @objc func moveResultPage(){
        performSegue(withIdentifier: "goToMockResultPage",sender: nil)
    }
    
    // 結果画面に渡す変数
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToMockResultPage" {
            
            // 対象の画面（クイズ画面）
            let destioantionVC = segue.destination as! QuizResultController
            
            // クイズ問題
            destioantionVC.questions = self.questions
            
            // 答え
            destioantionVC.answers = self.answers
            
            // ユーザーが選択した答え
            destioantionVC.userChoices = self.userChoices
            
            // 正誤表
            destioantionVC.results = self.results
            
            // 正解数
            destioantionVC.correctCount = correctCount
            
            // クイズの種類
            destioantionVC.quizType = 1 // Mock Exam
            
            // 問題数
            destioantionVC.numberOfQuestions = questions.count
            
            // 変数を初期化
            correctCount = 0
            questionNumber = 0
            list.removeAll()
            questions.removeAll()
            answers.removeAll()
            //            sounds.removeAll()
            choices.removeAll()
            results.removeAll()
            userChoices.removeAll()
        }
    }
}

//MARK:- AVAudioPlayerDelegate
extension MockExamController: AVAudioPlayerDelegate {
    
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
extension MockExamController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController is MockExamMenuController {
            // タイマーを停止
            self.timer?.invalidate()
        }
    }
}
