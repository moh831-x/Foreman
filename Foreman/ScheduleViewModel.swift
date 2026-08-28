import Foundation
import Combine
import FirebaseFirestore

@MainActor
final class ScheduleViewModel: ObservableObject {
    @Published var shifts: [Shift] = []
    @Published var weekOffset: Int = 0 {
        didSet { subscribe() }
    }

    private var listener: ListenerRegistration?
    private let db = Firestore.firestore()

    var weekId: String { Self.weekId(for: weekOffset) }
    var weekDates: [Date] { Self.weekDates(for: weekOffset) }

    var weekLabel: String {
        let dates = weekDates
        guard let first = dates.first, let last = dates.last else { return "" }
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        let fYear = DateFormatter()
        fYear.dateFormat = "MMM d, yyyy"
        return "\(f.string(from: first)) – \(fYear.string(from: last))"
    }

    func subscribe() {
        listener?.remove()
        listener = db.collection("shifts")
            .whereField("week", isEqualTo: weekId)
            .addSnapshotListener { [weak self] snapshot, _ in
                guard let self, let docs = snapshot?.documents else { return }
                self.shifts = docs.compactMap { try? $0.data(as: Shift.self) }
            }
    }

    func shifts(for day: String) -> [Shift] {
        shifts.filter { $0.day == day }.sorted { $0.start < $1.start }
    }

    func addShift(day: String, employeeName: String, start: String, end: String, createdBy: String) {
        let shift = Shift(week: weekId, day: day, employeeName: employeeName, start: start, end: end, createdBy: createdBy)
        _ = try? db.collection("shifts").addDocument(from: shift)
    }

    func deleteShift(_ shift: Shift) {
        guard let id = shift.id else { return }
        db.collection("shifts").document(id).delete()
    }

    static func weekDates(for offset: Int) -> [Date] {
        var calendar = Calendar(identifier: .iso8601)
        calendar.firstWeekday = 2
        let now = Date()
        let weekday = calendar.component(.weekday, from: now)
        let daysFromMonday = (weekday + 5) % 7
        guard let startOfToday = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: now),
              let monday = calendar.date(byAdding: .day, value: -daysFromMonday + offset * 7, to: startOfToday)
        else { return [] }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: monday) }
    }

    static func weekId(for offset: Int) -> String {
        guard let monday = weekDates(for: offset).first else { return "" }
        var calendar = Calendar(identifier: .iso8601)
        calendar.firstWeekday = 2
        let week = calendar.component(.weekOfYear, from: monday)
        let year = calendar.component(.yearForWeekOfYear, from: monday)
        return "\(year)-W\(String(format: "%02d", week))"
    }

    deinit { listener?.remove() }
}
