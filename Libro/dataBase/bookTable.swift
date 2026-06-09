import SwiftData
import Foundation

@Model
final class Book {
    var id: UUID = UUID()
    var bookName: String?
    var bookImage: String?
    var bookAuthor: String?
    var bookGoal: String?
    var reflection: String?
    var bookRate: Float?
    var status: String?
    var currentPage: Int = 0
    var totalPages: Int = 0
    var lastReadDate: Date?          // ← أضف هذا السطر فقط

    var user: User?

    @Relationship(deleteRule: .cascade, inverse: \Session.book)
    var sessions: [Session]? = []

    @Relationship(deleteRule: .cascade, inverse: \Journey.book)
    var journey: Journey?

    init(bookName: String, bookImage: String, bookGoal: String,
         reflection: String, bookRate: Float, status: String,
         totalPages: Int = 0) {
        self.bookName   = bookName
        self.bookImage  = bookImage
        self.bookGoal   = bookGoal
        self.reflection = reflection
        self.bookRate   = bookRate
        self.status     = status
        self.totalPages = totalPages
    }

    var progress: Double {
        guard totalPages > 0 else { return 0 }
        return min(Double(currentPage) / Double(totalPages), 1.0)
    }

    var goalType: String {
        bookGoal?.components(separatedBy: ":").first ?? ""
    }

    var goalValue: Int {
        guard let part = bookGoal?.components(separatedBy: ":").last,
              let value = Int(part) else { return 0 }
        return value
    }
}
