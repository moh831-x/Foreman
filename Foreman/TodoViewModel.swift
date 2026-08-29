import Foundation
import Combine
import FirebaseFirestore

@MainActor
final class TodoViewModel: ObservableObject {
    @Published var todos: [TodoItem] = []

    private var listener: ListenerRegistration?
    private let db = Firestore.firestore()

    func subscribe() {
        listener?.remove()
        listener = db.collection("todos")
            .addSnapshotListener { [weak self] snapshot, _ in
                guard let self, let docs = snapshot?.documents else { return }
                self.todos = docs.compactMap { try? $0.data(as: TodoItem.self) }
                    .sorted { !$0.done && $1.done }
            }
    }

    func add(text: String, dueDay: String?, week: String, createdBy: String?) {
        let item = TodoItem(text: text, dueDay: dueDay, week: week, done: false, createdBy: createdBy)
        _ = try? db.collection("todos").addDocument(from: item)
    }

    func toggle(_ item: TodoItem) {
        guard let id = item.id else { return }
        db.collection("todos").document(id).updateData(["done": !item.done])
    }

    func update(_ item: TodoItem, text: String, dueDay: String?) {
        guard let id = item.id else { return }
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        let dueValue: Any = dueDay.map { $0 as Any } ?? NSNull()
        db.collection("todos").document(id).updateData([
            "text": trimmed,
            "dueDay": dueValue
        ])
    }

    func delete(_ item: TodoItem) {
        guard let id = item.id else { return }
        db.collection("todos").document(id).delete()
    }

    deinit { listener?.remove() }
}
