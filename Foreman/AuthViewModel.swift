import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var isSignedIn: Bool = false
    @Published var currentUser: UserProfile?
    @Published var errorMessage: String?
    @Published var justPunchedIn: Bool = false

    private var handle: AuthStateDidChangeListenerHandle?
    private let db = Firestore.firestore()

    init() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self else { return }
            Task { await self.handleAuthChange(user) }
        }
    }

    deinit {
        if let handle { Auth.auth().removeStateDidChangeListener(handle) }
    }

    private func handleAuthChange(_ user: FirebaseAuth.User?) async {
        guard let user else {
            isSignedIn = false
            currentUser = nil
            return
        }
        do {
            let doc = try await db.collection("users").document(user.uid).getDocument()
            if let profile = try? doc.data(as: UserProfile.self) {
                currentUser = profile
            } else {
                currentUser = UserProfile(name: user.email ?? "Crew", email: user.email ?? "", role: .employee)
            }
        } catch {
            currentUser = UserProfile(name: user.email ?? "Crew", email: user.email ?? "", role: .employee)
        }
        isSignedIn = true
    }

    func signIn(email: String, password: String) async {
        errorMessage = nil
        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
            justPunchedIn = true
        } catch {
            errorMessage = Self.friendlyMessage(error)
        }
    }

    func signUp(name: String, email: String, password: String) async {
        errorMessage = nil
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Let us know your name first."
            return
        }
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            let profile = UserProfile(name: name, email: email, role: .employee)
            try db.collection("users").document(result.user.uid).setData(from: profile)
            justPunchedIn = true
        } catch {
            errorMessage = Self.friendlyMessage(error)
        }
    }

    func signOut() {
        try? Auth.auth().signOut()
    }

    static func friendlyMessage(_ error: Error) -> String {
        let nsError = error as NSError
        switch AuthErrorCode(rawValue: nsError.code) {
        case .wrongPassword, .userNotFound, .invalidCredential:
            return "That email or password doesn't match our records."
        case .emailAlreadyInUse:
            return "That email's already punched in — try logging in instead."
        case .weakPassword:
            return "Password needs to be at least 6 characters."
        case .invalidEmail:
            return "That email address doesn't look right."
        default:
            return "Something went wrong. Give it another shot."
        }
    }
}
