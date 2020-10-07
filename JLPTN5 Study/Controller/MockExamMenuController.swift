//
//  MockExamMenuController.swift
//  JLPTN5 Study
//
//  Created by 尾野順哉 on 2020/09/22.
//  Copyright © 2020 NAOYA ONO. All rights reserved.
//

import UIKit
import GoogleMobileAds

class MockExamMenuController: UIViewController, GADInterstitialDelegate {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var titleLabel: UILabel! // 問題タイトル
    @IBOutlet weak var titleView: UIView!    
    @IBOutlet weak var bannerView: GADBannerView!
    
    var type: Int? // クイズの種類（語彙 or 漢字）
    
    var interstitial: GADInterstitial!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        
        // 広告を作成し読み込む
        interstitial = createAndLoadInterstitial()
        
        initView()        
    }
    
    // インタースティシャル広告を作成し読み込む
    func createAndLoadInterstitial() -> GADInterstitial {

        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
        interstitial.delegate = self
        interstitial.load(GADRequest())
        return interstitial
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
    
    // 広告をクリックして開いた画面を閉じた直後に呼ばれる
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {

        // ⑥ 新たな広告を作成し読み込む
        interstitial = createAndLoadInterstitial()
    }
    
    func initView() {
        
        // タイトルカラー
        titleLabel.textColor = UIColor(named: "textColorbase")
        
        // ナビゲーションの設定
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
                
        switch self.type {
        case 0:
            title = "Vocabulary Mock Exam"
        case 1:
            title = "Kanji Mock Exam"
        case 2:
            title = "Grammar Mock Exam"
        default:
            title = "No Title"
        }
        
        titleView.layer.cornerRadius = 10
        
        // 影をセット
        titleView.layer.shadowColor = UIColor.black.cgColor //　影の色
        titleView.layer.shadowOpacity = 0.2  //影の濃さ
        titleView.layer.shadowRadius = 3.0 // 影のぼかし量
        titleView.layer.shadowOffset = CGSize(width: 1.0, height: 1.0) // 影の方向

        // 語彙
        if type == 0 {
            titleLabel.attributedText = NSAttributedString(string: "（ 　　　）に　なにを　いれますか。１・２・３・４から　いちばん　いい　ものを　ひとつ　えらんで　ください。", lineSpacing: 20.0, alignment: .left)
            
        } else if type == 1 {
            // 漢字
            titleLabel.attributedText = NSAttributedString(string: "（ 　　　）の　ことばは　ひらがなで　どう　かきますか。１・２・３・４から　いちばん　いい　ものを　ひとつ　えらんで　ください。", lineSpacing: 20.0, alignment: .left)
        }
        else if type == 2 {
            // 文法
            titleLabel.attributedText = NSAttributedString(string: "（ 　　　）に　なにを　いれますか。１・２・３・４から　いちばん　いい　ものを　ひとつ　えらんで　ください。", lineSpacing: 20.0, alignment: .left)
        }
    }
    

    @IBAction func valueChanged(_ sender: UISegmentedControl) {
        if segmentedControl.selectedSegmentIndex == 0 {
            if type == 0 {
                titleLabel.attributedText = NSAttributedString(string: "（ 　　　）に　なにを　いれますか。１・２・３・４から　いちばん　いい　ものを　ひとつ　えらんで　ください。", lineSpacing: 20.0, alignment: .left)
            } else if type == 1 {
                titleLabel.attributedText = NSAttributedString(string: "（ 　　　）の　ことばは　ひらがなで　どう　かきますか。１・２・３・４から　いちばん　いい　ものを　ひとつ　えらんで　ください。", lineSpacing: 20.0, alignment: .left)
            } else if type == 2 {
                titleLabel.attributedText = NSAttributedString(string: "（ 　　　）に　なにを　いれますか。１・２・３・４から　いちばん　いい　ものを　ひとつ　えらんで　ください。", lineSpacing: 20.0, alignment: .left)
            }
        }else if segmentedControl.selectedSegmentIndex == 1 {
            if type == 0 {
                titleLabel.attributedText = NSAttributedString(string: "（　　）の　ぶんと　だいたい　おなじ　いみの　ぶんがあります。１・２・３・４から　いちばん　いい　ものを　ひとつ　えらんで　ください。", lineSpacing: 20.0, alignment: .left)
            } else if type == 1 {
                titleLabel.attributedText = NSAttributedString(string: "（　　　）の　ことばは　どう　かきますか。１・２・３・４から　いちばん　いい　ものを　ひとつ　えらんで　ください。", lineSpacing: 20.0, alignment: .left)
            } else if type == 2 {
                titleLabel.attributedText = NSAttributedString(string: "（　★　）に　はいる　ものは　どれですか。１・２・３・４から　いちばん　いい　ものを　ひとつ　えらんで　ください。", lineSpacing: 20.0, alignment: .left)
            }
        }
    }
        
    @IBAction func startButtonPressed(_ sender: UIButton) {
        
        // 広告の表示準備ができていれば、表示する
         if interstitial.isReady {
           interstitial.present(fromRootViewController: self)
         }
        
        // 試験ページへジャンプする
        self.performSegue(withIdentifier: "goToMockExamPage", sender: nil)
        
    }
    
    // 次の画面へ渡す値
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToMockExamPage" {
            // 対象の画面（クイズ画面）
            let destioantionVC = segue.destination as! MockExamController

            // クイズタイプ（語彙 or　漢字）
            destioantionVC.type = self.type

            // part（1：語彙 or 2：漢字 or 3：文法）
            destioantionVC.part = (self.segmentedControl.selectedSegmentIndex) + 1
        }
    }    
}
