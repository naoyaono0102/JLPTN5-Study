//
//  Kanji.swift
//  JLPTN5 Study
//
//  Created by 尾野順哉 on 2020/09/16.
//  Copyright © 2020 NAOYA ONO. All rights reserved.
//

import Foundation
import RealmSwift

class Kanji: Object {
    @objc dynamic var kanji: String = ""
    @objc dynamic var reading: String = ""
    @objc dynamic var sound: String = ""
    let parent = LinkingObjects(fromType: KanjiCategory.self, property: "items") // リレーション
}
