//
//  Counters.swift
//  JLPTN5 Study
//
//  Created by 尾野順哉 on 2020/10/07.
//  Copyright © 2020 NAOYA ONO. All rights reserved.
//

import Foundation
import RealmSwift

class Counters: Object {
    @objc dynamic var english: String = ""
    @objc dynamic var smallThings: String = ""
    @objc dynamic var people: String = ""
    @objc dynamic var equipment: String = ""
    @objc dynamic var flatThings: String = ""
    @objc dynamic var longOThings: String = ""
    @objc dynamic var age: String = ""
    @objc dynamic var hours: String = ""
    @objc dynamic var minutes: String = ""
    @objc dynamic var order: Int = 0
}
