
import SwiftData
import Foundation


@Model
final class Journey {
   var id: UUID = UUID()

   var book: Book?

   init() {}
}
