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

    var id: UUID = UUID()
    var userName: String?
    var userIcon: String?
    var streak: Int?
    
    init(
        userName: String,
        userIcon: String,
        streak : Int
    ) {
        self.userName = userName
        self.userIcon = userIcon
        self.streak = streak
    }
}
