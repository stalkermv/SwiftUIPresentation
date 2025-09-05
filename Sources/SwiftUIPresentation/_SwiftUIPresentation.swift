// The Swift Programming Language
// https://docs.swift.org/swift-book

struct User: Identifiable, Hashable, Codable {
    var id: String
    var name: String
    
    static let users = [
        User(id: "1", name: "Alice"),
        User(id: "2", name: "Bob"),
        User(id: "3", name: "Charlie")
    ]
}

struct Post: Identifiable, Hashable, Codable {
    var id: String
    var title: String
}

import SwiftUI

struct ContentView: View {
    @State private var path = PresentationPath()
    
    var body: some View {
        PresentationStack(path: $path) {
            VStack {
                ForEach(User.users) { user in
                    NavigationLink(value: user) {
                        Text(user.name)
                    }

                    PresentationLink(value: user) {
                        Text(user.name)
                    }
                }
            }
            .presentationDestination(for: User.self) { user in
                UserView(user: user)
                    .presentationCompactAdaptation(.fullScreenCover)
            }
           
        }
        .onChange(of: path) { oldValue, newValue in
            print("PresentationPath changed from to \(newValue)")
        }
    }
}

struct UserView: View {
    let user: User
    
    var body: some View {
        VStack {
            Text("User ID: \(user.id)")
            Text("User Name: \(user.name)")
            
            NavigationLink(value: Post(id: "1", title: "First Post")) {
                Text("Go to Post")
            }
            
            PresentationLink(value: Post(id: "1", title: "First Post")) {
                Text("Go to Post via PresentationLink")
            }
        }
        .navigationTitle(user.name)
        .presentationDestination(for: Post.self) { post in
            Text("Post Title: \(post.title)")
        }
    }
}

#Preview {
    ContentView()
}
