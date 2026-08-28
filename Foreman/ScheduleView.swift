import SwiftUI

struct ScheduleView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var vm = ScheduleViewModel()
    @State private var addingShiftForDay: String?

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
        }
        .background(Color.foremanPaper.ignoresSafeArea())
        .onAppear { vm.subscribe() }
        .sheet(item: $addingShiftForDay) { day in
            AddShiftSheet(day: day) { employee, start, end in
                vm.addShift(day: day, employeeName: employee, start: start, end: end,
                            createdBy: authVM.currentUser?.email ?? "")
            }
        }
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

            if isAdmin {
                Button {
                    addingShiftForDay = day
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
}

extension String: @retroactive Identifiable {
    public var id: String { self }
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
