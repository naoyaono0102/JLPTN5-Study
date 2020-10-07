//
//  Vocabulary.swift
//  JLPTN5 Study
//
//  Created by 尾野順哉 on 2020/09/15.
//  Copyright © 2020 NAOYA ONO. All rights reserved.
//

import Foundation
import RealmSwift

class Vocabulary: Object {
    @objc dynamic var english: String = ""
    @objc dynamic var japanese: String = ""
    @objc dynamic var sound: String = ""
    let parent = LinkingObjects(fromType: VocabularyCategory.self, property: "items") // リレーション

//    let parents = LinkingObjects(fromType: VocabularyCategory.self, property: "items")
//    var parent:VocabularyCategory? {
//        return self.parents.first
//    }
    
    //    //主キーの設定（必要な場合）
    //    override static func primaryKey() -> String? {
    //      return "english" // 主キーの名称
    //    }
}
