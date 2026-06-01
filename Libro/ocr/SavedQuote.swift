import SwiftData
import UIKit

@Model
final class SavedQuote {
    var id: UUID
    var extractedText: String
    var bookImageData: Data?
    var createdAt: Date

    init(extractedText: String, bookImageData: Data? = nil) {
        self.id = UUID()
        self.extractedText = extractedText
        self.bookImageData = bookImageData
        self.createdAt = Date()
    }

    var bookImage: UIImage? {
        guard let data = bookImageData else { return nil }
        return UIImage(data: data)
    }
}
