import Vision
import UIKit

enum OCRError: LocalizedError {
    case noTextFound
    case processingFailed(Error)

    var errorDescription: String? {
        switch self {
        case .noTextFound:      return "لم يتم العثور على نص في الصورة"
        case .processingFailed(let e): return "فشل معالجة الصورة: \(e.localizedDescription)"
        }
    }
}

final class OCRService {

    func recognizeText(in image: UIImage) async throws -> String {
        // نجرب عربي أولاً، لو فشل نجرب إنجليزي
        if let result = try? await recognize(image, languages: ["ar-SA"]), !result.isEmpty {
            return result
        }
        if let result = try? await recognize(image, languages: ["en-US"]), !result.isEmpty {
            return result
        }
        return try await recognize(image, languages: [])
    }

    private func recognize(_ image: UIImage, languages: [String]) async throws -> String {
        guard let cgImage = image.cgImage else { throw OCRError.noTextFound }

        // ← هنا الإصلاح: نمرر الـ orientation لـ Vision
        // بدونه يقرأ الصورة بشكل خاطئ إذا كانت من الكاميرا
        let orientation = cgImageOrientation(from: image.imageOrientation)

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error {
                    continuation.resume(throwing: OCRError.processingFailed(error))
                    return
                }
                let observations = request.results as? [VNRecognizedTextObservation] ?? []
                let text = observations
                    .compactMap { $0.topCandidates(1).first?.string }
                    .joined(separator: "\n")
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                if text.isEmpty {
                    continuation.resume(throwing: OCRError.noTextFound)
                } else {
                    continuation.resume(returning: text)
                }
            }

            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = false
            if !languages.isEmpty {
                request.recognitionLanguages = languages
            }

            do {
                // نستخدم النسخة اللي تقبل orientation بدل ما نمرر cgImage مجردة
                let handler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation, options: [:])
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: OCRError.processingFailed(error))
            }
        }
    }

    // تحويل UIImage.Orientation → CGImagePropertyOrientation
    private func cgImageOrientation(from uiOrientation: UIImage.Orientation) -> CGImagePropertyOrientation {
        switch uiOrientation {
        case .up:            return .up
        case .down:          return .down
        case .left:          return .left
        case .right:         return .right
        case .upMirrored:    return .upMirrored
        case .downMirrored:  return .downMirrored
        case .leftMirrored:  return .leftMirrored
        case .rightMirrored: return .rightMirrored
        @unknown default:    return .up
        }
    }
}
