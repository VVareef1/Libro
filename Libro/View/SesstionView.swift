//
//  SesstionView.swift
//  Libro
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
    @State private var navDestination: NavDestination? = nil

    private var bookPages: Int { book.totalPages }

    enum NavDestination: Hashable {
        case summary
        case congrats
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.97, green: 0.95, blue: 0.91).ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    Text(viewModel.formattedTime)
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundColor(Color("buttons"))
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
                                .foregroundColor(Color("lightGray"))
                                .frame(width: 70, height: 52)
                                .background(Color("buttons"))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }

                        Button(action: { viewModel.openNoteSheet() }) {
                            Image(systemName: "pencil.and.scribble")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(Color("lightGray"))
                                .frame(width: 70, height: 52)
                                .background(Color("buttons"))
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
            .navigationDestination(item: $navDestination) { destination in
                switch destination {
                case .summary:
                    BookSessionView1(
                        session: BookSession(
                            bookName: book.bookName ?? "",
                            date: Date(),
                            timeSpent: Double(viewModel.elapsedSeconds),
                            stoppedPage: stoppedPage,
                            notes: viewModel.notes
                        ),
                        bookPages: book.totalPages
                    )
                case .congrats:
                    CongratulationView(book: book)
                }
            }
            .alert("End Session?", isPresented: $showEndConfirmation) {
                Button("End Session", role: .destructive) {
                    viewModel.stop()
                    if book.goalType == "Pages" {
                        showPageAlert = true
                    } else {
                        saveSession(stoppedAt: 0)
                        navDestination = .summary
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to end this session?")
            }
            .alert("What page did you stop on?", isPresented: $showPageAlert) {
                TextField("Page number", text: $pageInput)
                    .keyboardType(.numberPad)
                Button("Done") {
                    let page = Int(pageInput) ?? 0
                    stoppedPage = page
                    saveSession(stoppedAt: page)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        navDestination = page >= bookPages ? .congrats : .summary
                    }
                }
                Button("Skip", role: .cancel) {
                    saveSession(stoppedAt: 0)
                    navDestination = .summary
                }
            }
        }
        .navigationBarBackButtonHidden(true)

    }

    // MARK: - حفظ الجلسة وتحديث البروجرس والستريك

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

        if book.goalType == "Pages", page > 0 {
            book.currentPage = page
        } else if book.goalType == "Time" {
            let pagesRead = viewModel.elapsedSeconds / 120
            book.currentPage = min(book.currentPage + pagesRead, book.totalPages)
        }

        if book.totalPages > 0 && book.currentPage >= book.totalPages {
            book.status = "finished"
        }

        if goalAchieved() {
            updateStreak()
        }

        do {
            try modelContext.save()
            print("✅ Session saved | progress: \(Int(book.progress * 100))% | streak: \(book.user?.streak ?? 0)")
        } catch {
            print("❌ Error: \(error)")
        }
    }

    // MARK: - هل حقق الهدف؟

    private func goalAchieved() -> Bool {
        if book.goalType == "Pages" {
            let pagesReadToday = stoppedPage - (book.sessions?.dropLast().last?.stoppedPage ?? 0)
            return pagesReadToday >= book.goalValue
        } else if book.goalType == "Time" {
            return viewModel.elapsedSeconds >= book.goalValue
        }
        return false
    }

    // MARK: - تحديث الستريك

    private func updateStreak() {
        guard let user = book.user else { return }

        let calendar = Calendar.current
        let today    = calendar.startOfDay(for: Date())

        if let lastDate = user.lastStreakDate {
            let last = calendar.startOfDay(for: lastDate)

            if last == today {
                return
            } else if calendar.dateComponents([.day], from: last, to: today).day == 1 {
                user.streak = (user.streak ?? 0) + 1
            } else {
                user.streak = 0
            }
        } else {
            user.streak = 1
        }

        user.lastStreakDate = today
    }
}

#Preview {
    let book = Book(bookName: "Atomic Habits", bookImage: "", bookGoal: "Pages:30",
                    reflection: "", bookRate: 0, status: "reading", totalPages: 320)
    CandleTimerView(book: book)
        .modelContainer(for: [Book.self, Session.self, User.self], inMemory: true)
}
