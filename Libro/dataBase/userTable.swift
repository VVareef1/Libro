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
    
    // لازم نحذ الاوبشينال (؟) عند المتغيرات عشان مايطلع لي ايرورز بالكلاود كيت
    
    
    var id: UUID = UUID() // و ال id خلوه بنفس الطريقة ذي
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
