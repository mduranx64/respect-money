//
//  Item.swift
//  RespectMoney
//
//  Created by Miguel Duran on 13-03-25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
