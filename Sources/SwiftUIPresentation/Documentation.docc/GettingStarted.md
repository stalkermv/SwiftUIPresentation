# Getting Started

Learn the smallest viable setup for mixed stack and modal navigation.

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
                PresentationLink(value: user) {
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
PresentationLink(value: user, method: .stack) {
    Text("Navigate to Profile")  
}

// You can also use native NavigationLink for stack navigation
NavigationLink(value: user) {
    Text("Stack Navigation")
}
```

## Native SwiftUI Integration

Use one destination registration and choose the modal host from the destination:

```swift
.presentationDestination(for: User.self) { user in
    UserProfileView(user: user)
        .presentationAdaptation(.fullScreenCover)
        .presentationDetents([.large])
}

.presentationDestination(for: Document.self) { document in
    DocumentView(document: document)
        .presentationAdaptation(.popover)
}
```

On runtimes earlier than iOS 18, SwiftUIPresentation falls back to a standard
sheet host.

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
                path.append(User(id: UUID(), name: "Blob"))
                path.present(SettingsData(), over: .root)
            }
        }
    }
}
```

## Next steps

Read about the underlying concepts in <doc:Concepts>.
