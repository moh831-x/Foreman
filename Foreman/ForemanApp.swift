import SwiftUI

@main
struct ForemanApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var authVM = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authVM)
        }
    }
}

struct RootView: View {
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        Group {
            if authVM.isSignedIn {
                MainTabView()
            } else {
                AuthView()
            }
        }
        .animation(.easeInOut, value: authVM.isSignedIn)
    }
}
