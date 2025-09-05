# Getting Started

Learn the basics of creating mixed navigation flows.

## Basic setup

Start by wrapping your content in a ``PresentationStack`` and registering
destinations for your data types:

```swift
import SwiftUIPresentation

struct ContentView: View {
    @State private var path = PresentationPath()
    
    var body: some View {
        PresentationStack(path: $path) {
            List(users) { user in
                PresentationLink(value: user, presentationType: .stack) {
                    Text(user.name)
                }
            }
            .presentationDestination(for: User.self) { user in
                UserProfile(user: user)
            }
        }
    }
}
```

## Navigation styles

Use the same destination for different presentation styles:

```swift
// Default sheet presentation  
PresentationLink(value: user) {
    Text("View Profile")
}

// Explicit stack navigation
PresentationLink(value: user, presentationType: .stack) {
    Text("Navigate to Profile")  
}

// You can also use native NavigationLink for stack navigation
NavigationLink(value: user) {
    Text("Stack Navigation")
}
```

## Native SwiftUI Integration

All native SwiftUI presentation and navigation modifiers work seamlessly:

```swift
.presentationDestination(for: User.self) { user in
    UserProfileView(user: user)
        // Native presentation modifiers
        .presentationDetents([.medium, .large])
        .presentationCompactAdaptation(.fullScreenCover)
        .presentationBackground(.regularMaterial)
        .interactiveDismissDisabled()
        .presentationCornerRadius(20)
}

.presentationDestination(for: Document.self) { document in
    DocumentView(document: document)
        // Native navigation modifiers
        .navigationTransition(.zoom(sourceID: document.id, in: namespace))
        .toolbarRole(.editor)
        .navigationBarTitleDisplayMode(.inline)
}
```

## Multiple data types

Register destinations for each type you want to navigate to:

```swift
PresentationStack {
    // Your content
    .presentationDestination(for: User.self) { user in
        UserProfile(user: user)
    }
    .presentationDestination(for: Document.self) { document in
        DocumentViewer(document: document)
    }
}
```

## Programmatic navigation

Use the environment router for navigation from anywhere in your view hierarchy:

```swift
struct UserProfile: View {
    @Environment(\.presentation) private var router
    let user: User
    
    var body: some View {
        VStack {
            // View content
            
            Button("Show Settings") {
                router?.present(value: SettingsData())
            }
            
            Button("Go Back") {
                router?.pop()
            }
        }
    }
}
```

You can also manipulate the path directly:

```swift
struct ContentView: View {
    @State private var path = PresentationPath()
    
    var body: some View {
        PresentationStack(path: $path) {
            Button("Navigate Programmatically") {
                path.append(User(id: 1))
                path.present(SettingsData(), over: .root)
            }
        }
    }
}
```

## Next steps

Read about the underlying concepts in <doc:Concepts>.
