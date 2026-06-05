import Foundation

struct TimerModel {
    var totalSeconds: Int = 0
    var isRunning: Bool = false

    var hours: Int   { totalSeconds / 3600 }
    var minutes: Int { (totalSeconds % 3600) / 60 }
    var seconds: Int { totalSeconds % 60 }

    var formattedTime: String {
        String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
