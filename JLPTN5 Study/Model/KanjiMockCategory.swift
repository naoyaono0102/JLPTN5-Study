//
//  KanjiMockCategory.swift
//  
//
//  Created by 尾野順哉 on 2020/09/22.
//

import Foundation
import RealmSwift

class KanjiMockCategory: Object {
    @objc dynamic var part: Int = 0
    let items = List<KanjiMock>() // リレーション
    
    //主キーの設定
    override static func primaryKey() -> String? {
      return "part"
    }
}
