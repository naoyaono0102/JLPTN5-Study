//
//  Conjugation.swift
//  JLPTN5 Study
//
//  Created by 尾野順哉 on 2020/09/29.
//  Copyright © 2020 NAOYA ONO. All rights reserved.
//

import Foundation
import RealmSwift

class Conjugation: Object {
    @objc dynamic var naiForm: String = ""
    @objc dynamic var masuForm: String = ""
    @objc dynamic var jishoForm: String = ""
    @objc dynamic var teForm: String = ""
    @objc dynamic var taForm: String = ""
    @objc dynamic var order: Int = 0
}
