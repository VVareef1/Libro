

import SwiftData
import Foundation

@Model
final class User {
    var id: UUID = UUID()
    var userName: String?
    var userIcon: String?
    var streak: Int?
 
    @Relationship(deleteRule: .cascade, inverse: \Library.user)
    var library: Library?
 
    @Relationship(deleteRule: .cascade, inverse: \Book.user)
    var books: [Book]? = []
 
    init(userName: String, userIcon: String, streak: Int) {
        self.userName = userName
        self.userIcon = userIcon
        self.streak   = streak
    }
}
