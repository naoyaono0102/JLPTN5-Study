//
//  VocabularyMock.swift
//  JLPTN5 Study
//
//  Created by 尾野順哉 on 2020/09/22.
//  Copyright © 2020 NAOYA ONO. All rights reserved.
//

import Foundation
import RealmSwift

class VocabularyMock: Object {
    @objc dynamic var question: String = ""
    @objc dynamic var answer: String = ""
    @objc dynamic var wrong1: String = ""
    @objc dynamic var wrong2: String = ""
    @objc dynamic var wrong3: String = ""
    let parent = LinkingObjects(fromType: VocabularyMockCategory.self, property: "items") // リレーション
}

