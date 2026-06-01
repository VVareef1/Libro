import SwiftUI
import UIKit

struct CropView: View {
    let image: UIImage
    let onCrop: (UIImage) -> Void
    let onCancel: () -> Void

    // The actual rendered frame of the image inside the ZStack (global coords)
    @State private var renderedImageFrame: CGRect = .zero

    @State private var dragStart: CGPoint = .zero
    @State private var dragEnd:   CGPoint = .zero
    @State private var isDragging = false

    private var selectionRect: CGRect {
        CGRect(
            x: min(dragStart.x, dragEnd.x),
            y: min(dragStart.y, dragEnd.y),
            width:  abs(dragEnd.x - dragStart.x),
            height: abs(dragEnd.y - dragStart.y)
        )
    }

    private var hasSelection: Bool {
        selectionRect.width > 20 && selectionRect.height > 20
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                GeometryReader { geo in
                    ZStack(alignment: .center) {

                        // ── Image ──────────────────────────────────────────
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: geo.size.width, height: geo.size.height)
                            // Capture the exact rendered frame in global coords
                            .background(
                                GeometryReader { imgGeo in
                                    Color.clear.onAppear {
                                        renderedImageFrame = imgGeo.frame(in: .global)
                                    }
                                    .onChange(of: geo.size) { _, _ in
                                        renderedImageFrame = imgGeo.frame(in: .global)
                                    }
                                }
                            )

                        // ── Dim overlay with cutout ────────────────────────
                        if isDragging || hasSelection {
                            SelectionOverlay(
                                selection: selectionRect,
                                containerSize: geo.size
                            )
                        }

                        // ── Selection border + handles ─────────────────────
                        if hasSelection {
                            SelectionBorder(rect: selectionRect)
                        }
                    }
                    .frame(width: geo.size.width, height: geo.size.height)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 4, coordinateSpace: .local)
                            .onChanged { value in
                                if !isDragging {
                                    dragStart  = value.startLocation
                                    isDragging = true
                                }
                                dragEnd = value.location
                            }
                            .onEnded { _ in
                                isDragging = false
                            }
                    )
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("إلغاء") { onCancel() }
                        .foregroundStyle(.white)
                }
                ToolbarItem(placement: .principal) {
                    Text("حدد الاقتباس")
                        .foregroundStyle(.white)
                        .fontWeight(.medium)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("تأكيد") { cropAndProceed() }
                        .disabled(!hasSelection)
                        .foregroundStyle(hasSelection ? Color.yellow : Color.gray)
                        .fontWeight(.semibold)
                }
            }
            .safeAreaInset(edge: .bottom) {
                if !hasSelection {
                    Text("اسحب على الصفحة لتحديد الكلام")
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.7))
                        .padding(.bottom, 16)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Crop

    private func cropAndProceed() {
        guard hasSelection, renderedImageFrame != .zero else { return }
        guard let cropped = cropImage(image, selection: selectionRect, imageFrame: renderedImageFrame) else { return }
        onCrop(cropped)
    }

    /// Maps a selection rect in **local GeometryReader space** to image pixel coords,
    /// using the actual rendered frame of the image (captured via .global GeometryReader).
    ///
    /// The GeometryReader gives us the frame in .global. The drag gesture uses .local
    /// coords inside that same GeometryReader, so local == global - geoOrigin.
    private func cropImage(_ uiImage: UIImage, selection: CGRect, imageFrame: CGRect) -> UIImage? {
        let imageSize = uiImage.size

        // scaledToFit scale factor: how much the image was shrunk to fit the view
        let scaleX = imageFrame.width  / imageSize.width
        let scaleY = imageFrame.height / imageSize.height
        let scale  = min(scaleX, scaleY)   // scaledToFit uses the smaller axis

        // Rendered image size inside the frame
        let renderedW = imageSize.width  * scale
        let renderedH = imageSize.height * scale

        // Offset of the image inside the GeometryReader frame (centering letterbox)
        // imageFrame is in .global; the drag is in .local of the same GeometryReader,
        // so we only need the intra-frame offset, not the global origin.
        let offsetX = (imageFrame.width  - renderedW) / 2
        let offsetY = (imageFrame.height - renderedH) / 2

        // Convert selection (local coords) → image logical pixels
        let cropX = max(0, (selection.minX - offsetX) / scale)
        let cropY = max(0, (selection.minY - offsetY) / scale)
        let cropW = min(imageSize.width  - cropX, selection.width  / scale)
        let cropH = min(imageSize.height - cropY, selection.height / scale)

        guard cropW > 0, cropH > 0 else { return nil }

        // UIImage.scale: retina images have scale == 2 or 3; CGImage coords are in pixels
        let px = uiImage.scale
        let cropRect = CGRect(
            x: cropX * px, y: cropY * px,
            width: cropW * px, height: cropH * px
        )

        guard let cgImage = uiImage.cgImage?.cropping(to: cropRect) else { return nil }
        return UIImage(cgImage: cgImage, scale: uiImage.scale, orientation: uiImage.imageOrientation)
    }
}

// MARK: - Selection Overlay (dim + cutout)

struct SelectionOverlay: View {
    let selection: CGRect
    let containerSize: CGSize

    var body: some View {
        Canvas { context, _ in
            context.fill(
                Path(CGRect(origin: .zero, size: containerSize)),
                with: .color(.black.opacity(0.55))
            )
            context.blendMode = .clear
            context.fill(Path(selection), with: .color(.white))
        }
        .allowsHitTesting(false)
        .frame(width: containerSize.width, height: containerSize.height)
    }
}

// MARK: - Selection Border + Corner Handles

struct SelectionBorder: View {
    let rect: CGRect

    var body: some View {
        ZStack {
            // Border
            Rectangle()
                .strokeBorder(Color.white, lineWidth: 1.5)
                .frame(width: rect.width, height: rect.height)
                .position(x: rect.midX, y: rect.midY)

            // Rule-of-thirds grid lines
            Path { p in
                let x1 = rect.minX + rect.width  / 3
                let x2 = rect.minX + rect.width  * 2 / 3
                let y1 = rect.minY + rect.height / 3
                let y2 = rect.minY + rect.height * 2 / 3
                p.move(to: CGPoint(x: x1, y: rect.minY)); p.addLine(to: CGPoint(x: x1, y: rect.maxY))
                p.move(to: CGPoint(x: x2, y: rect.minY)); p.addLine(to: CGPoint(x: x2, y: rect.maxY))
                p.move(to: CGPoint(x: rect.minX, y: y1)); p.addLine(to: CGPoint(x: rect.maxX, y: y1))
                p.move(to: CGPoint(x: rect.minX, y: y2)); p.addLine(to: CGPoint(x: rect.maxX, y: y2))
            }
            .stroke(Color.white.opacity(0.3), lineWidth: 0.5)

            // Corner handles
            ForEach(corners(of: rect), id: \.self) { pt in
                cornerHandle(at: pt)
            }
        }
    }

    private func corners(of r: CGRect) -> [CGPoint] {
        [r.origin,
         CGPoint(x: r.maxX, y: r.minY),
         CGPoint(x: r.minX, y: r.maxY),
         CGPoint(x: r.maxX, y: r.maxY)]
    }

    @ViewBuilder
    private func cornerHandle(at point: CGPoint) -> some View {
        Circle()
            .fill(Color.white)
            .frame(width: 12, height: 12)
            .position(point)
    }
}

extension CGPoint: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x); hasher.combine(y)
    }
}
