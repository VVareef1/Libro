import Foundation
import Combine

@MainActor
final class CandleTimerViewModel: ObservableObject {

    @Published private(set) var formattedTime: String = "00:00:00"
    @Published private(set) var isRunning: Bool = false
    @Published var showNoteSheet: Bool = false
    @Published private(set) var notes: [BookNote] = []

    private var model = TimerModel()
    private var timer: DispatchSourceTimer?


    func onAppear() {
        syncPublished()
        start()
    }

    func togglePlayPause() {
        isRunning ? pause() : start()
    }

    func openNoteSheet() {
        showNoteSheet = true
    }

    func addNote(text: String, page: Int) {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        notes.append(BookNote(text: text, page: page))
        showNoteSheet = false
    }

    func stop() {
        stopTimer()
        model.isRunning = false
        syncPublished()
    }

    var elapsedSeconds: Int { model.totalSeconds }


    private func start() {
        stopTimer()
        model.isRunning = true
        syncPublished()

        let t = DispatchSource.makeTimerSource(queue: .main)
        t.schedule(deadline: .now() + 1, repeating: 1.0, leeway: .milliseconds(50))
        t.setEventHandler { [weak self] in
            guard let self else { return }
            self.model.totalSeconds += 1  
            self.syncPublished()
        }
        t.resume()
        timer = t
    }

    private func pause() {
        stopTimer()
        model.isRunning = false
        syncPublished()
    }

    private func stopTimer() {
        timer?.cancel()
        timer = nil
    }


    private func syncPublished() {
        formattedTime = model.formattedTime
        isRunning = model.isRunning
    }
}
