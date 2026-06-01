
import SwiftData
import Foundation

@Model
final class Library {
   var id: UUID = UUID()
   var completedBooks: [String]? = []
   var wishlistBooks: [String]?  = []

   var user: User?

   init(completedBooks: [String], wishlistBooks: [String]) {
       self.completedBooks = completedBooks
       self.wishlistBooks  = wishlistBooks
   }
}
