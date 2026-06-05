import Foundation

struct TimerModel {
    var totalSeconds: Int
    var isRunning: Bool
    var isEditing: Bool

    var hours: Int   { totalSeconds / 3600 }
    var minutes: Int { (totalSeconds % 3600) / 60 }
    var seconds: Int { totalSeconds % 60 }

    var formattedTime: String {
        String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    init(hours: Int = 0, minutes: Int = 0, seconds: Int = 0) {
        self.totalSeconds = hours * 3600 + minutes * 60 + seconds
        self.isRunning = false
        self.isEditing = false
    }
}
