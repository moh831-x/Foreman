import SwiftUI

struct AuthView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var mode: Mode = .login
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var isSubmitting = false

    enum Mode { case login, signup }

    var body: some View {
        ZStack {
            Color.foremanInk.ignoresSafeArea()
            PegboardBackground().ignoresSafeArea()

            ScrollView {
                VStack(spacing: 28) {
                    VStack(spacing: 6) {
                        Text("FOREMAN")
                            .font(.system(size: 40, weight: .black, design: .rounded))
                            .foregroundColor(.foremanPaper)
                        Text("CREW BOARD & WEEKLY SCHEDULE")
                            .font(.system(size: 11, weight: .semibold))
                            .tracking(1.5)
                            .foregroundColor(.foremanPaperDim)
                    }
                    .padding(.top, 60)

                    ZStack {
                        cardContent
                        if authVM.justPunchedIn {
                            StampView(text: "PUNCHED IN")
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
    }

    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 20) {
                tabButton("PUNCH IN", isActive: mode == .login) { mode = .login }
                tabButton("NEW CREW MEMBER", isActive: mode == .signup) { mode = .signup }
                Spacer()
            }
            .overlay(Rectangle().fill(Color.foremanInk.opacity(0.14)).frame(height: 2), alignment: .bottom)
            .padding(.bottom, 4)

            if let error = authVM.errorMessage {
                Text(error)
                    .font(.system(size: 12.5))
                    .foregroundColor(.foremanBrick)
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.foremanBrick.opacity(0.12))
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.foremanBrick, lineWidth: 1.5))
                    .cornerRadius(4)
            }

            if mode == .signup {
                labeledField("YOUR NAME", text: $name)
            }
            labeledField("EMAIL", text: $email, keyboard: .emailAddress)
            labeledSecureField("PASSWORD", text: $password)

            Button {
                Task {
                    isSubmitting = true
                    if mode == .login {
                        await authVM.signIn(email: email, password: password)
                    } else {
                        await authVM.signUp(name: name, email: email, password: password)
                    }
                    isSubmitting = false
                }
            } label: {
                Text(mode == .login ? "Punch In" : "Join the Board")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(ForemanButtonStyle(kind: .primary))
            .disabled(isSubmitting || email.isEmpty || password.isEmpty)
        }
        .padding(24)
        .background(Color.foremanPaper)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.foremanInk, lineWidth: 2))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.35), radius: 0, x: 8, y: 8)
    }

    private func tabButton(_ title: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .tracking(0.4)
                .foregroundColor(isActive ? .foremanInk : .foremanSteel)
                .padding(.bottom, 8)
                .overlay(
                    Rectangle().fill(isActive ? Color.foremanAmber : .clear).frame(height: 3),
                    alignment: .bottom
                )
        }
    }

    private func labeledField(_ label: String, text: Binding<String>, keyboard: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.system(size: 11, weight: .semibold)).tracking(0.8).foregroundColor(.foremanSteel)
            TextField("", text: text)
                .keyboardType(keyboard)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding(10)
                .background(Color.foremanPaper)
                .overlay(RoundedRectangle(cornerRadius: 3).stroke(Color.foremanInk, lineWidth: 2))
        }
    }

    private func labeledSecureField(_ label: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.system(size: 11, weight: .semibold)).tracking(0.8).foregroundColor(.foremanSteel)
            SecureField("", text: text)
                .padding(10)
                .background(Color.foremanPaper)
                .overlay(RoundedRectangle(cornerRadius: 3).stroke(Color.foremanInk, lineWidth: 2))
        }
    }
}

/// The "PUNCHED IN [time]" stamp that slams onto the card on successful auth.
struct StampView: View {
    let text: String
    @State private var appeared = false

    var body: some View {
        Text("\(text) \(Self.timeString())")
            .font(.system(size: 18, weight: .black))
            .tracking(1.0)
            .padding(.vertical, 6)
            .padding(.horizontal, 14)
            .foregroundColor(.foremanBrick)
            .overlay(RoundedRectangle(cornerRadius: 2).stroke(Color.foremanBrick, lineWidth: 3))
            .rotationEffect(.degrees(-10))
            .scaleEffect(appeared ? 1 : 2.2)
            .opacity(appeared ? 1 : 0)
            .blendMode(.multiply)
            .onAppear {
                withAnimation(.easeOut(duration: 0.45)) { appeared = true }
            }
    }

    static func timeString() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: Date())
    }
}
