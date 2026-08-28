import SwiftUI

struct TodoListView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var vm = TodoViewModel()
    @StateObject private var scheduleVM = ScheduleViewModel()

    @State private var newText = ""
    @State private var newDueDay: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("THE LIST")
                .font(.system(size: 20, weight: .black))
                .foregroundColor(.foremanInk)
                .padding([.horizontal, .top])
                .padding(.bottom, 10)

            if vm.todos.isEmpty {
                Text("Nothing on the list. Foreman's slacking.")
                    .font(.system(size: 12.5))
                    .italic()
                    .foregroundColor(.foremanSteel)
                    .padding(.horizontal)
            }

            List {
                ForEach(vm.todos) { item in
                    HStack(alignment: .top, spacing: 10) {
                        Button {
                            vm.toggle(item)
                        } label: {
                            Image(systemName: item.done ? "checkmark.square.fill" : "square")
                                .foregroundColor(item.done ? .foremanAmber : .foremanSteel)
                                .font(.system(size: 19))
                        }
                        .buttonStyle(.plain)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.text)
                                .font(.system(size: 14.5))
                                .strikethrough(item.done)
                                .foregroundColor(item.done ? .foremanSteel : .foremanInk)
                            if let due = item.dueDay {
                                Text(due.uppercased())
                                    .font(.system(size: 10, weight: .bold))
                                    .padding(.horizontal, 6).padding(.vertical, 2)
                                    .background(Color.foremanBrick)
                                    .foregroundColor(.foremanPaper)
                                    .cornerRadius(3)
                            }
                        }
                        Spacer()
                    }
                    .listRowBackground(Color.foremanPaper)
                    .swipeActions {
                        Button(role: .destructive) { vm.delete(item) } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .listStyle(.plain)
            .background(Color.foremanPaper)

            addRow
        }
        .background(Color.foremanPaper.ignoresSafeArea())
        .onAppear {
            vm.subscribe()
            scheduleVM.subscribe()
        }
    }

    private var addRow: some View {
        VStack(spacing: 8) {
            Divider()
            HStack(spacing: 8) {
                TextField("Add a task…", text: $newText)
                    .padding(10)
                    .background(Color.white.opacity(0.5))
                    .overlay(RoundedRectangle(cornerRadius: 3).stroke(Color.foremanInk, lineWidth: 1.5))

                Menu {
                    Button("No due day") { newDueDay = nil }
                    ForEach(weekdays, id: \.self) { day in
                        Button(day) { newDueDay = day }
                    }
                } label: {
                    Text(newDueDay ?? "Day")
                        .font(.system(size: 12, weight: .semibold))
                        .padding(.horizontal, 10).padding(.vertical, 10)
                        .overlay(RoundedRectangle(cornerRadius: 3).stroke(Color.foremanInk, lineWidth: 1.5))
                        .foregroundColor(.foremanInk)
                }

                Button {
                    guard !newText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                    vm.add(text: newText, dueDay: newDueDay, week: scheduleVM.weekId,
                           createdBy: authVM.currentUser?.email)
                    newText = ""
                    newDueDay = nil
                } label: {
                    Text("Add")
                }
                .buttonStyle(ForemanButtonStyle(kind: .primary))
            }
            .padding(.horizontal)
            .padding(.bottom, 12)
        }
    }
}
