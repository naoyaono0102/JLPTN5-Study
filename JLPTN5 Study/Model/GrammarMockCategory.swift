//
//  GrammarMockCategory.swift
//  JLPTN5 Study
//
//  Created by 尾野順哉 on 2020/09/28.
//  Copyright © 2020 NAOYA ONO. All rights reserved.
//

import Foundation
import RealmSwift

class GrammarMockCategory: Object {
    @objc dynamic var part: Int = 0
    let items = List<GrammarMock>() // リレーション
    
    //主キーの設定
    override static func primaryKey() -> String? {
      return "part"
    }
}
