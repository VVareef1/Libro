//
//  userTable.swift
//  Libro
//
//  Created by wessal hashim alharbi on 19/05/2026.
//

import SwiftData
import Foundation

@Model
final class User {

    var id: UUID
    var userName: String
    var userIcon: String
    var streak: Int
    
    init(
        id: UUID = UUID(),
        userName: String,
        userIcon: String,
        streak : Int
    ) {
        self.id = id
        self.userName = userName
        self.userIcon = userIcon
        self.streak = streak
    }
}
