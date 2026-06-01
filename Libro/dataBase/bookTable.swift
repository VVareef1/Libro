import SwiftData
import Foundation


@Model
final class Book {
   var id: UUID = UUID()
   var bookName: String?
   var bookImage: String?
   var bookGoal: String?
   var reflection: String?
   var bookRate: Float?
   var status: String?

   var user: User?

   @Relationship(deleteRule: .cascade, inverse: \Session.book)
   var sessions: [Session]? = []

   @Relationship(deleteRule: .cascade, inverse: \Journey.book)
   var journey: Journey?

   init(bookName: String, bookImage: String, bookGoal: String,
        reflection: String, bookRate: Float, status: String) {
       self.bookName   = bookName
       self.bookImage  = bookImage
       self.bookGoal   = bookGoal
       self.reflection = reflection
       self.bookRate   = bookRate
       self.status     = status
   }
}
