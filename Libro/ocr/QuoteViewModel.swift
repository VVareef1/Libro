import SwiftUI
import PhotosUI

@MainActor
@Observable
final class QuoteViewModel {

    // MARK: - State
    enum Step: Equatable {
        case idle
        case cropping(UIImage)
        case processing
        case result(text: String, image: UIImage)
        case error(String)

        static func == (lhs: Step, rhs: Step) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle), (.processing, .processing): return true
            case (.result(let t1, _), .result(let t2, _)):   return t1 == t2
            case (.error(let e1), .error(let e2)):            return e1 == e2
            default: return false
            }
        }
    }

    var step: Step = .idle
    var showCamera = false
    var showPhotosPicker = false
    var selectedPhotoItem: PhotosPickerItem?

    private let ocrService = OCRService()

    // MARK: - Actions

    func handleCapturedImage(_ image: UIImage) {
        step = .cropping(image)
    }

    func handleCroppedImage(_ cropped: UIImage, original: UIImage) {
        Task { await processImage(cropped, fullImage: original) }
    }

    func handlePhotoPickerSelection(_ item: PhotosPickerItem?) async {
        guard let item else { return }
        guard let data = try? await item.loadTransferable(type: Data.self),
              let image = UIImage(data: data) else { return }
        step = .cropping(image)
    }

    func reset() {
        step = .idle
    }

    // MARK: - Private

    private func processImage(_ cropped: UIImage, fullImage: UIImage) async {
        step = .processing
        do {
            let text = try await ocrService.recognizeText(in: cropped)
            step = .result(text: text, image: fullImage)
        } catch {
            step = .error("تعذّر قراءة النص: \(error.localizedDescription)")
        }
    }
}
