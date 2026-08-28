import Foundation
import FirebaseFirestore
enum Role: String, Codable {
    case admin
    case employee
}

struct UserProfile: Codable {
    var name: String
    var email: String
    var role: Role
}

struct Shift: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var week: String
    var day: String
    var employeeName: String
    var start: String
    var end: String
    var createdBy: String
}

struct TodoItem: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var text: String
    var dueDay: String?
    var week: String?
    var done: Bool
    var createdBy: String?
}

let weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
