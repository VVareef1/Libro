import SwiftData
import Foundation

@Model
final class book {

    var id: UUID
    var bookName: String
    var bookImage: String

    // Goals
    var timeGoal: Date?
    var pageGoal: Int?

    // Reflection
    var bookReflection: String

    // Rating
    var bookRate: Double

    // Reading Status
    var bookStatus: Bool

    init(
        id: UUID = UUID(),
        bookName: String,
        bookImage: String,
        timeGoal: Date? = nil,
        pageGoal: Int? = nil,
        bookReflection: String = "",
        bookRate: Double = 0.0,
        bookStatus: Bool = false
    ) {
        self.id = id
        self.bookName = bookName
        self.bookImage = bookImage
        self.timeGoal = timeGoal
        self.pageGoal = pageGoal
        self.bookReflection = bookReflection
        self.bookRate = bookRate
        self.bookStatus = bookStatus
    }
}
