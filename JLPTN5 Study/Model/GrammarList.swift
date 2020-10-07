//
//  GrammarList.swift
//  JLPTN5 Study
//
//  Created by 尾野順哉 on 2020/09/29.
//  Copyright © 2020 NAOYA ONO. All rights reserved.
//

import Foundation
import RealmSwift

class GrammarList: Object {
    @objc dynamic var english: String = ""
    @objc dynamic var japanese: String = ""
    @objc dynamic var order: Int = 0
}
