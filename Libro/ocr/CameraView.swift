import SwiftUI
import UIKit

struct CameraView: View {
    let onCrop: (UIImage, UIImage) -> Void
    let onCancel: () -> Void

    @State private var capturedImage: UIImage?

    var body: some View {
        if let image = capturedImage {
            CropView(image: image) { cropped in
                onCrop(cropped, image)
            } onCancel: {
                capturedImage = nil
            }
        } else {
            CameraPickerView { image in
                // ← نصلح الـ orientation قبل ما نمرر الصورة لـ CropView
                capturedImage = image.fixedOrientation()
            } onCancel: {
                onCancel()
            }
        }
    }
}

// MARK: - UIImagePickerController Wrapper

struct CameraPickerView: UIViewControllerRepresentable {
    let onCapture: (UIImage) -> Void
    let onCancel: () -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        // نخلي الكاميرا تعرض بشكل portrait طبيعي
        picker.cameraDevice = .rear
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraPickerView
        init(_ parent: CameraPickerView) { self.parent = parent }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let image = info[.originalImage] as? UIImage {
                parent.onCapture(image)
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.onCancel()
        }
    }
}

// MARK: - UIImage orientation fix

extension UIImage {
    /// يرسم الصورة من جديد بـ orientation صحيح (.up)
    /// الكاميرا ترجع صور بـ orientation مختلف حسب كيف تمسك الجهاز
    func fixedOrientation() -> UIImage {
        guard imageOrientation != .up else { return self }

        let format = UIGraphicsImageRendererFormat()
        format.scale = scale

        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
