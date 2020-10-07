//
//  KanjiQuizMode.swift
//  JLPTN5 Study
//
//  Created by 尾野順哉 on 2020/09/28.
//  Copyright © 2020 NAOYA ONO. All rights reserved.
//

import Foundation
import RealmSwift

class KanjiQuizMode: Object {
    @objc dynamic var quizMode: Int = 0 // reading or writing
    let questions = List<KanjiQuiz>() // リレーション（子）
    let parent = LinkingObjects(fromType: KanjiCategory.self, property: "quizModes") // リレーション（親）
}
