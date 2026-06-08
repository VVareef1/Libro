

import SwiftData
import Foundation

@Model
final class Session {
    var id: UUID = UUID()
    var timer: Int?
    var date: Date?
    var duration: Int?
    var stoppedPage: Int?
    var quote: [String]? = []     // ← array
    var quotePageNumber: [Int]? = []  // ← array للصفحات
    var book: Book?

    init(timer: Int, date: Date, duration: Int,
         stoppedPage: Int, quote: [String], quotePageNumber: [Int]) {
        self.timer           = timer
        self.date            = date
        self.duration        = duration
        self.stoppedPage     = stoppedPage
        self.quote           = quote
        self.quotePageNumber = quotePageNumber
    }
}
