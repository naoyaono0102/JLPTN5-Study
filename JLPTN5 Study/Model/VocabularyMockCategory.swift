//
//  VocabularyMockCategory.swift
//  JLPTN5 Study
//
//  Created by 尾野順哉 on 2020/09/22.
//  Copyright © 2020 NAOYA ONO. All rights reserved.
//

import Foundation
import RealmSwift

class VocabularyMockCategory: Object {
    @objc dynamic var part: Int = 0
    let items = List<VocabularyMock>() // リレーション
    
    //主キーの設定
    override static func primaryKey() -> String? {
      return "part"
    }
}
