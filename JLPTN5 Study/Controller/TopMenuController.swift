//
//  ViewController.swift
//  JLPTN5 Study
//
//  Created by 尾野順哉 on 2020/09/07.
//  Copyright © 2020 NAOYA ONO. All rights reserved.
//

import UIKit

class TopMenuController: UIViewController {
    
    // セルのレイアウト設定
    private let sectionInsets = UIEdgeInsets(top: 0, left: 15, bottom: 25, right: 15)
    // 1行あたりのアイテム数
    private var itemsPerRow: CGFloat = 2
    
    // 表示するセクション
    let sectionLabels: [String] = ["Vocabulary", "Kanji", "Grammar"]
    
    // 表示するラベル
    let titleLabels: [[String]] = [
        ["Flashcard", "Quiz", "Vocabulary List", "Mock Exam"],
        ["Flashcard", "Quiz", "Kanji List", "Mock Exam"],
        ["Flashcard", "Grammar List", "Mock Exam"]
    ]
    
    // クイズのタイプ（語彙・漢字）
    private var type: Int? // 0：語彙、1：漢字、2：文法
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
    }
    
    // Viewの初期設定
    func initView(){
        // ナビゲーションの設定
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationController!.navigationBar.isTranslucent = false //色を薄くしない
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor // 影の色
        self.navigationController?.navigationBar.layer.shadowRadius = 3.5 // 影のぼかし量
        self.navigationController?.navigationBar.layer.shadowOpacity = 0.3 // 影の濃さ
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 1.0, height: 1.0) // 影の方向
    }
}


extension TopMenuController: UICollectionViewDataSource {
    
    // セクション数
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sectionLabels.count
    }
    
    // セル数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titleLabels[section].count
    }
    
    // セルに値をセット
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // widthReuseIdentifierにはStoryboardで設定したセルのIDを指定
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
        // セルに値をセット
        let title = cell.contentView.viewWithTag(1) as! UILabel
        let cardIcon = cell.contentView.viewWithTag(2) as! UIImageView
        
        if indexPath.section == 2 {
            switch indexPath.row {
            case 0:
                cardIcon.image = UIImage(named: "vocabulary-icon")!
            case 1:
                cardIcon.image = UIImage(named: "list-icon")!
            case 2:
                cardIcon.image = UIImage(named: "exam-icon")!
            default:
                print("該当無し")
            }
        } else {
            switch indexPath.row {
            case 0:
                cardIcon.image = UIImage(named: "vocabulary-icon")!
            case 1:
                cardIcon.image = UIImage(named: "question-icon")!
            case 2:
                cardIcon.image = UIImage(named: "list-icon")!
            case 3:
                cardIcon.image = UIImage(named: "exam-icon")!
            default:
                print("該当無し")
            }
        }
        
        
        title.text = titleLabels[indexPath.section][indexPath.row]
        title.adjustsFontSizeToFitWidth = true
        
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
        
        //ヘッダーの場合
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeader", for: indexPath) as? SectionHeader else {
            fatalError("ヘッダーがありません")
        }
        
        // ヘッダーラベルにタイトルをセット
        if kind == UICollectionView.elementKindSectionHeader {
            header.sectionHeader.text = sectionLabels[indexPath.section]
            return header
        }
        return UICollectionReusableView()
    }
    
    
}

// セルをタップしたときの処理
extension TopMenuController: UICollectionViewDelegate {
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
                
                // カテゴリーチェック
                self.typeCheck(indexPath.section)
                
                if self.type == 2 {
                    // 画面遷移
                    if indexPath.row == 0 {
                        self.performSegue(withIdentifier: "goToFlashCardMenu", sender: nil)  // フラッシュカードメニュー画面へ遷移
                    } else if indexPath.row == 1 {
                        self.performSegue(withIdentifier: "jumpToListPage", sender: nil) // リストへ
                    } else if indexPath.row == 2 {
                        self.performSegue(withIdentifier: "goToMockMenu", sender: nil) // 模擬試験へ
                    }
                } else {
                    // 画面遷移
                    if indexPath.row == 0 {
                        self.performSegue(withIdentifier: "goToFlashCardMenu", sender: nil)  // フラッシュカードメニュー画面へ遷移
                    } else if indexPath.row == 1 {
                        self.performSegue(withIdentifier: "goToQuizMenu", sender: nil) // ４択クイズ画面へ遷移
                    } else if indexPath.row == 2 {
                        self.performSegue(withIdentifier: "goToListMenu", sender: nil) // リストへ
                    } else if indexPath.row == 3 {
                        self.performSegue(withIdentifier: "goToMockMenu", sender: nil) // 模擬試験へ
                    }
                }
            }
        }
    }
    
    // クイズのタイプ（語彙・漢字を判別する）
    func typeCheck(_ section: Int){
        if section == 0 {
            self.type = 0 // 語彙
            
        } else if section == 1 {
            self.type = 1 // 漢字
        } else if section == 2 {
            self.type = 2 // 文法
        }
    }
    // 次の画面に渡す変数
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
        case "goToFlashCardMenu":
            // フラッシュカードへ
            let destioantionVC = segue.destination as! FlashCardMenuController
            // クイズタイプを渡す（語彙 or 漢字 or 文法）
            destioantionVC.type = type
        case "goToQuizMenu":
            // ４択クイズへ
            let destioantionVC = segue.destination as! QuizMenuController
            // クイズタイプを渡す（語彙 or 漢字）
            destioantionVC.type = type
        case "goToListMenu":
            // リストメニューへ
            let destioantionVC = segue.destination as! ListMenuController
            // クイズタイプを渡す（語彙 or 漢字 or 文法）
            destioantionVC.type = type
        case "goToMockMenu":
            // 模擬テスト
            let destioantionVC = segue.destination as! MockExamMenuController
            // クイズタイプを渡す（語彙 or 漢字）
            destioantionVC.type = type
        case "jumpToListPage":
            // 模擬テスト
            let destioantionVC = segue.destination as! ListController
            destioantionVC.type = type
        default:
            print("該当無し")
        }
    }
}

// セルのサイズを調整する
extension TopMenuController: UICollectionViewDelegateFlowLayout {
    
    // Screenサイズに応じたセルサイズを返す
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem/1.5)
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

// UILabelの開業幅
extension NSAttributedString {
    convenience init(string: String, lineSpacing: CGFloat, alignment: NSTextAlignment) {
        var attributes: [NSAttributedString.Key: Any] = [:]
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.alignment = alignment
        attributes.updateValue(paragraphStyle, forKey: .paragraphStyle)
        self.init(string: string, attributes: attributes)
    }
}
