import Foundation

enum FDADateFormatter {
    private static let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyyMMdd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    private static let displayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f
    }()

    static func parse(_ dateString: String) -> Date? {
        formatter.date(from: dateString)
    }

    static func displayString(from fdaDate: String) -> String {
        guard let date = parse(fdaDate) else { return fdaDate }
        return displayFormatter.string(from: date)
    }
}
