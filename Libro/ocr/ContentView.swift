import SwiftUI
import PhotosUI

struct ContentView2: View {
    @State private var viewModel = QuoteViewModel()
    @State private var extractedText = ""

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            VStack(spacing: 24) {

                // ── زر التصوير ─────────────────────────────────────────
                Button {
                    viewModel.showCamera = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "camera.fill")
                            .font(.title3)
                        Text("صوّر وحدد الاقتباس")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)

                // ── تيكست بوكس ─────────────────────────────────────────
                TextEditor(text: $extractedText)
                    .font(.body)
                    .lineSpacing(5)
                    .padding(14)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color(.separator), lineWidth: 0.5)
                    )
                    .overlay(alignment: .topLeading) {
                        if extractedText.isEmpty {
                            Text("النص المستخرج يظهر هنا...")
                                .foregroundStyle(.tertiary)
                                .padding(20)
                                .allowsHitTesting(false)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
            }

            // ── Processing overlay ──────────────────────────────────────
            if case .processing = viewModel.step {
                ZStack {
                    Color.black.opacity(0.35).ignoresSafeArea()
                    VStack(spacing: 14) {
                        ProgressView().scaleEffect(1.4).tint(.white)
                        Text("جاري استخراج النص...")
                            .font(.subheadline).foregroundStyle(.white)
                    }
                    .padding(32)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
            }
        }
        .environment(viewModel)

        // ── الكاميرا ────────────────────────────────────────────────────
        .fullScreenCover(isPresented: $viewModel.showCamera) {
            CameraView { cropped, original in
                viewModel.showCamera = false
                viewModel.handleCroppedImage(cropped, original: original)
            } onCancel: {
                viewModel.showCamera = false
            }
        }

        // ── لما يطلع النص نحطه في التيكست بوكس ─────────────────────────
        .onChange(of: viewModel.step) { _, step in
            if case .result(let text, _) = step {
                extractedText = text
                viewModel.reset()
            }
        }

        // ── Error ───────────────────────────────────────────────────────
        .alert("حدث خطأ", isPresented: Binding(
            get: { if case .error = viewModel.step { return true }; return false },
            set: { if !$0 { viewModel.reset() } }
        )) {
            Button("حسناً", role: .cancel) { viewModel.reset() }
        } message: {
            if case .error(let msg) = viewModel.step { Text(msg) }
        }
    }
}
