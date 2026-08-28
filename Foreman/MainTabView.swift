import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        NavigationView {
            TabView {
                ScheduleView()
                    .tabItem { Label("This Week", systemImage: "calendar") }
                TodoListView()
                    .tabItem { Label("To-Do List", systemImage: "checklist") }
            }
            .navigationTitle("Foreman")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        if let user = authVM.currentUser {
                            Text("\(user.name) · \(user.role.rawValue.uppercased())")
                        }
                        Button("Punch Out", role: .destructive) { authVM.signOut() }
                    } label: {
                        Image(systemName: "person.crop.circle")
                    }
                }
            }
        }
        .accentColor(.foremanInk)
    }
}
