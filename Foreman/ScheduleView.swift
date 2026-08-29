import SwiftUI

struct ScheduleView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var vm = ScheduleViewModel()
    @StateObject private var todoVM = TodoViewModel()
    @State private var addingShiftForDay: DaySelection?
    @State private var editingTask: TodoItem?

    private var isAdmin: Bool { authVM.currentUser?.role == .admin }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button { vm.weekOffset -= 1 } label: {
                    Text("← Prior Week")
                }
                .buttonStyle(ForemanButtonStyle(kind: .ghost))
                .tint(.foremanInk)

                Spacer()
                Text(vm.weekLabel)
                    .font(.system(size: 13))
                    .foregroundColor(.foremanSteel)
                Spacer()

                Button { vm.weekOffset += 1 } label: {
                    Text("Next Week →")
                }
                .buttonStyle(ForemanButtonStyle(kind: .ghost))
                .tint(.foremanInk)
            }
            .padding()

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 10) {
                    ForEach(Array(zip(weekdays, vm.weekDates)), id: \.0) { day, date in
                        dayColumn(day: day, date: date)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.foremanPaper.ignoresSafeArea())
        .onAppear {
            vm.subscribe()
            todoVM.subscribe()
        }
        .sheet(item: $addingShiftForDay) { selection in
            AddShiftSheet(day: selection.day) { employee, start, end in
                vm.addShift(day: selection.day, employeeName: employee, start: start, end: end,
                            createdBy: authVM.currentUser?.email ?? "")
            }
        }
        .sheet(item: $editingTask) { task in
            EditNoteSheet(
                note: task,
                onSave: { text, dueDay in todoVM.update(task, text: text, dueDay: dueDay) },
                onDelete: { todoVM.delete(task) }
            )
        }
    }

    private func tasksFor(_ day: String) -> [TodoItem] {
        todoVM.todos.filter { $0.dueDay == day && ($0.week == nil || $0.week == vm.weekId) }
    }

    private func dayColumn(day: String, date: Date) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(day.uppercased())
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.foremanInk)
            Text(date, format: .dateTime.month(.abbreviated).day())
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(.foremanSteel)

            let dayShifts = vm.shifts(for: day)
            if dayShifts.isEmpty {
                Text("No shifts posted.")
                    .font(.system(size: 11.5))
                    .italic()
                    .foregroundColor(.foremanSteel)
            } else {
                ForEach(dayShifts) { shift in
                    shiftRow(shift)
                }
            }

            let dayTasks = tasksFor(day)
            if !dayTasks.isEmpty {
                Divider().padding(.vertical, 2)
                Text("NOTES")
                    .font(.system(size: 9.5, weight: .bold))
                    .foregroundColor(.foremanSteel)
                ForEach(dayTasks) { task in
                    taskChip(task)
                }
            }

            if isAdmin {
                Button {
                    addingShiftForDay = DaySelection(day: day)
                } label: {
                    Text("+ Shift").frame(maxWidth: .infinity)
                }
                .buttonStyle(ForemanButtonStyle(kind: .primary))
                .padding(.top, 6)
            }
        }
        .padding(10)
        .frame(width: 150, alignment: .topLeading)
        .background(Color.foremanPaperDim)
        .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.foremanInk.opacity(0.14), lineWidth: 1.5))
        .cornerRadius(5)
    }

    private func shiftRow(_ shift: Shift) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(shift.employeeName)
                    .font(.system(size: 12.5, weight: .semibold))
                Spacer()
                if isAdmin {
                    Button {
                        vm.deleteShift(shift)
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.foremanBrick)
                    }
                }
            }
            Text("\(shift.start)–\(shift.end)")
                .font(.system(size: 11.5, design: .monospaced))
                .foregroundColor(.foremanSteel)
        }
        .padding(6)
        .background(Color.foremanPaper)
        .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.foremanInk, lineWidth: 1.5))
        .cornerRadius(4)
    }

    private func taskChip(_ task: TodoItem) -> some View {
        Button {
            editingTask = task
        } label: {
            HStack(alignment: .top, spacing: 4) {
                Text(task.text)
                    .font(.system(size: 11.5))
                    .strikethrough(task.done)
                    .foregroundColor(task.done ? .foremanSteel : .foremanInk)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: "pencil")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.foremanSteel)
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 6)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.foremanAmber.opacity(0.16))
            .overlay(Rectangle().fill(Color.foremanAmber).frame(width: 3), alignment: .leading)
            .cornerRadius(2)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button { editingTask = task } label: {
                Label("Edit", systemImage: "pencil")
            }
            Button { todoVM.toggle(task) } label: {
                Label(task.done ? "Mark Not Done" : "Mark Done",
                      systemImage: task.done ? "arrow.uturn.backward" : "checkmark")
            }
            Button(role: .destructive) { todoVM.delete(task) } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

/// Wraps a weekday name so it can drive `.sheet(item:)` without making
/// `String` itself `Identifiable` across the whole module.
private struct DaySelection: Identifiable {
    let day: String
    var id: String { day }
}

struct AddShiftSheet: View {
    let day: String
    var onSave: (String, String, String) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var employee = ""
    @State private var start = Date()
    @State private var end = Date()

    var body: some View {
        NavigationView {
            Form {
                Section("Shift for \(day)") {
                    TextField("Employee name", text: $employee)
                    DatePicker("Starts", selection: $start, displayedComponents: .hourAndMinute)
                    DatePicker("Ends", selection: $end, displayedComponents: .hourAndMinute)
                }
            }
            .navigationTitle("Add Shift")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(employee, formatted(start), formatted(end))
                        dismiss()
                    }
                    .disabled(employee.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func formatted(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: date)
    }
}

/// Edit or delete a note attached to a day on the schedule.
struct EditNoteSheet: View {
    let note: TodoItem
    var onSave: (String, String?) -> Void
    var onDelete: () -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var text: String
    @State private var dueDay: String?
    @State private var confirmingDelete = false

    init(note: TodoItem, onSave: @escaping (String, String?) -> Void, onDelete: @escaping () -> Void) {
        self.note = note
        self.onSave = onSave
        self.onDelete = onDelete
        _text = State(initialValue: note.text)
        _dueDay = State(initialValue: note.dueDay)
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Note") {
                    TextField("Note", text: $text, axis: .vertical)
                        .lineLimit(1...5)
                }

                Section("Day") {
                    Picker("Day", selection: $dueDay) {
                        Text("No day").tag(String?.none)
                        ForEach(weekdays, id: \.self) { day in
                            Text(day).tag(String?.some(day))
                        }
                    }
                }

                Section {
                    Button(role: .destructive) {
                        confirmingDelete = true
                    } label: {
                        Label("Delete Note", systemImage: "trash")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .navigationTitle("Edit Note")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(text, dueDay)
                        dismiss()
                    }
                    .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .confirmationDialog("Delete this note?", isPresented: $confirmingDelete, titleVisibility: .visible) {
                Button("Delete", role: .destructive) {
                    onDelete()
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }
}
