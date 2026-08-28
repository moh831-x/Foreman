import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        TabView {
            NavigationStack {
                ScheduleView()
                    .navigationTitle("This Week")
                    .navigationBarTitleDisplayMode(.large)
                    .toolbar { accountMenu }
                    .toolbarBackground(Color.foremanPaper, for: .navigationBar)
                    .toolbarBackground(.visible, for: .navigationBar)
            }
            .tabItem { Label("This Week", systemImage: "calendar") }

            NavigationStack {
                TodoListView()
                    .navigationTitle("The List")
                    .navigationBarTitleDisplayMode(.large)
                    .toolbar { accountMenu }
                    .toolbarBackground(Color.foremanPaper, for: .navigationBar)
                    .toolbarBackground(.visible, for: .navigationBar)
            }
            .tabItem { Label("To-Do List", systemImage: "checklist") }
        }
        .tint(.foremanInk)
        .toolbarBackground(Color.foremanPaper, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }

    @ToolbarContentBuilder
    private var accountMenu: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Menu {
                if let user = authVM.currentUser {
                    Text("\(user.name) · \(user.role.rawValue.uppercased())")
                }
                Link("Privacy Policy", destination: URL(string: "https://wordpress-ab119.web.app/privacy.html")!)
                Link("Support", destination: URL(string: "https://wordpress-ab119.web.app/support.html")!)
                Button("Punch Out", role: .destructive) { authVM.signOut() }
            } label: {
                Image(systemName: "person.crop.circle")
            }
        }
    }
}
