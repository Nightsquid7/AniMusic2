//
//  Realm+.swift
//  iOS
//
//  Created by Steven Berkowitz on 2020/10/16.
//  Copyright © 2020 nightsquid. All rights reserved.
//

import RealmSwift

extension List {
    convenience init<T>(array: [T]) {
        self.init()
        for element in array {
            self.append(element as! Element)
        }
    }
}

extension List where Element == String {
    func asSourceTypes() -> [SourceType] {
        return self.compactMap { SourceType(rawValue: $0) }
    }
}
