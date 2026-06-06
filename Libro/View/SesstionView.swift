//
//  SesstionView.swift
//  Libro
//
//  Created by Eatzaz Hafiz on 04/06/2026.
//

import SwiftUI
import SwiftData

struct CandleTimerView: View {

    let book: Book

    @StateObject private var viewModel = CandleTimerViewModel()
    @Environment(\.modelContext) private var modelContext

    @State private var showEndConfirmation = false
    @State private var showPageAlert       = false
    @State private var pageInput:    String = ""
    @State private var stoppedPage:  Int    = 0
    @State private var navigateToSummary   = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.97, green: 0.95, blue: 0.91).ignoresSafeArea()

                NavigationLink(
                    destination: BookSessionView(
                        session: BookSession(
                            bookName: book.bookName ?? "",
                            date: Date(),
                            timeSpent: Double(viewModel.elapsedSeconds),
                            stoppedPage: stoppedPage,
                            notes: viewModel.notes
                        )
                    ),
                    isActive: $navigateToSummary
                ) { EmptyView() }

                VStack(spacing: 0) {
                    Spacer()

                    Text(viewModel.formattedTime)
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.42, green: 0.30, blue: 0.20))
                        .monospacedDigit()
                        .contentTransition(.numericText())
                        .animation(.default, value: viewModel.formattedTime)

                    Spacer()

                    Image("Candle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 500, height: 500)

                    Spacer()

                    HStack(spacing: 16) {
                        Button(action: { viewModel.togglePlayPause() }) {
                            Image(systemName: viewModel.isRunning ? "pause" : "play.fill")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 70, height: 52)
                                .background(Color(red: 0.42, green: 0.30, blue: 0.20))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }

                        Button(action: { viewModel.openNoteSheet() }) {
                            Image(systemName: "pencil.and.scribble")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 70, height: 52)
                                .background(Color(red: 0.42, green: 0.30, blue: 0.20))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    }
                    .padding(.bottom, 48)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showEndConfirmation = true }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(red: 0.42, green: 0.30, blue: 0.20))
                    }
                }
            }
            .toolbarBackground(Color(red: 0.97, green: 0.95, blue: 0.91), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear { viewModel.onAppear() }
            .sheet(isPresented: $viewModel.showNoteSheet) {
                NoteSheetView(viewModel: viewModel)
                    .presentationDetents([.height(420)])
                    .presentationDragIndicator(.hidden)
                    .presentationCornerRadius(24)
                    .interactiveDismissDisabled()
            }
            .alert("End Session?", isPresented: $showEndConfirmation) {
                Button("End Session", role: .destructive) {
                    viewModel.stop()
                    showPageAlert = true
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to end this session?")
            }
            .alert("What page did you stop on?", isPresented: $showPageAlert) {
                TextField("Page number", text: $pageInput)
                    .keyboardType(.numberPad)
                Button("Done") {
                    stoppedPage = Int(pageInput) ?? 0
                    saveSession(stoppedAt: stoppedPage)
                    navigateToSummary = true
                }
                Button("Skip", role: .cancel) {
                    saveSession(stoppedAt: 0)
                    navigateToSummary = true
                }
            }
        }
    }

    // MARK: - حفظ الجلسة وتحديث البروجرس

    private func saveSession(stoppedAt page: Int) {

        let session = Session(
            timer:           viewModel.elapsedSeconds,
            date:            Date(),
            duration:        viewModel.elapsedSeconds,
            stoppedPage:     page,
            quote:           viewModel.notes.first?.text ?? "",
            quotePageNumber: viewModel.notes.first?.page ?? 0
        )
        session.book = book
        book.sessions?.append(session)
        modelContext.insert(session)

        if page > 0 {
            book.currentPage = page
        }

        if book.totalPages > 0 && book.currentPage >= book.totalPages {
            book.status = "finished"
        }

        do {
            try modelContext.save()
            print("✅ Session saved, progress: \(Int(book.progress * 100))%")
        } catch {
            print("❌ Error: \(error)")
        }
    }
}

#Preview {
    let book = Book(bookName: "Atomic Habits", bookImage: "", bookGoal: "Pages:30",
                    reflection: "", bookRate: 0, status: "reading", totalPages: 320)
    CandleTimerView(book: book)
        .modelContainer(for: [Book.self, Session.self], inMemory: true)
}
