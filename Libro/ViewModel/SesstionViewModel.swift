import Foundation
import Combine

@MainActor
final class CandleTimerViewModel: ObservableObject {

    // MARK: - Published
    @Published private(set) var formattedTime: String = "00:00:00"
    @Published private(set) var isRunning: Bool = false

    // MARK: - Private
    private var model = TimerModel()
    private var timer: DispatchSourceTimer?

    // MARK: - Intents

    func onAppear() {
        syncPublished()
    }

    func togglePlayPause() {
        isRunning ? pause() : start()
    }

    func stop() {
        stopTimer()
        model.isRunning = false
        model.totalSeconds = 0
        syncPublished()
    }

    // MARK: - Timer control

    private func start() {
        stopTimer()
        guard model.totalSeconds > 0 else { return }

        model.isRunning = true
        syncPublished()

        let t = DispatchSource.makeTimerSource(queue: .main)
        t.schedule(deadline: .now() + 1, repeating: 1.0, leeway: .milliseconds(50))
        t.setEventHandler { [weak self] in
            guard let self else { return }
            if self.model.totalSeconds > 0 {
                self.model.totalSeconds -= 1
                self.syncPublished()
            } else {
                self.pause()
            }
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

    // MARK: - Sync

    private func syncPublished() {
        formattedTime = model.formattedTime
        isRunning = model.isRunning
    }
}
