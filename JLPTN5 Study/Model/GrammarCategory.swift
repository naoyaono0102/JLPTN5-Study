//
//  GrammarCategory.swift
//  JLPTN5 Study
//
//  Created by 尾野順哉 on 2020/09/29.
//  Copyright © 2020 NAOYA ONO. All rights reserved.
//

import Foundation
import RealmSwift

class GrammarCategory: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var order: Int = 0
    @objc dynamic var type: Int = 0 // 0:活用, 1:文型, 2：助数詞
    
    //主キーの設定
    override static func primaryKey() -> String? {
      return "name"
    }
}
