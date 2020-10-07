//
//  VocabularyCategory.swift
//  JLPTN5 Study
//
//  Created by 尾野順哉 on 2020/09/15.
//  Copyright © 2020 NAOYA ONO. All rights reserved.
//

import Foundation
import RealmSwift

class VocabularyCategory: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var order: Int = 0
    let items = List<Vocabulary>() // リレーション
    
    //主キーの設定
//    override static func primaryKey() -> String? {
//      return "name"
//    }
}
