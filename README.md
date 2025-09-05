# SwiftUIPresentation

A SwiftUI library that seamlessly combines stack navigation and modal sheets in a unified, testable API.

[![Swift 6.0+](https://img.shields.io/badge/Swift-6.0+-orange.svg)](https://swift.org)
[![iOS 17.0+](https://img.shields.io/badge/iOS-17.0+-blue.svg)](https://developer.apple.com/ios/)
[![macOS 14.0+](https://img.shields.io/badge/macOS-14.0+-blue.svg)](https://developer.apple.com/macos/)
[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Tests](https://github.com/stalkermv/SwiftUIPresentation/actions/workflows/tests.yml/badge.svg)](https://github.com/stalkermv/SwiftUIPresentation/actions/workflows/tests.yml)

## Overview

SwiftUIPresentation simplifies complex navigation by letting you describe *what* to show (data → view mappings) separately from *how* to show it (push vs sheet). A single `PresentationPath` tracks navigation state across multiple contexts, making your navigation logic easier to test and maintain.

## Features

- 🚀 **Unified Navigation**: One API for both stack pushes and sheet presentations
- 🎯 **Type-Safe**: Map data types to destination views with compile-time safety  
- 🔄 **Flexible Presentation**: Switch between stack and sheet with a single parameter
- 🧪 **Testable**: Programmatic control through value-based APIs
- 🏗️ **Isolated Contexts**: Sheets automatically get separate navigation namespaces
- 📱 **Modern SwiftUI**: Built for iOS 17+ and macOS 14+ with Swift 6 support

## Quick Start

```swift
import SwiftUIPresentation

struct ContentView: View {
    @State private var path = PresentationPath()
    
    var body: some View {
        PresentationStack(path: $path) {
            List(users) { user in
                // Push to stack
                PresentationLink(value: user, presentationType: .stack) {
                    Text(user.name)
                }
            }
            .presentationDestination(for: User.self) { user in
                UserDetailView(user: user)
            }
        }
    }
}
```

## Key Components

### PresentationStack
The main container that manages navigation state and provides environment access.

### PresentationLink  
A button-like view that triggers navigation. Choose between `.stack` (push) or `.sheet` (modal) presentation.

### PresentationPath
A value type that tracks navigation state across namespaces. Supports programmatic navigation.

### PresentationRouter
Environment-injected router for navigation from anywhere in your view hierarchy.

## Usage Examples

### Basic Navigation

```swift
// Sheet presentation (default behavior)
PresentationLink(value: user) {
    Text("View Profile") // Will show as sheet
}

// Explicit sheet presentation  
PresentationLink(value: user, presentationType: .sheet) {
    Text("Quick Edit")
}

// Stack navigation (explicit)
PresentationLink(value: user, presentationType: .stack) {
    Text("Navigate to Profile")
}

// You can also use native NavigationLink for stack navigation
NavigationLink(value: user) {
    Text("Native Stack Navigation")
}
```

### Native SwiftUI Integration

SwiftUIPresentation seamlessly integrates with native SwiftUI modifiers:

```swift
PresentationLink(value: settings) {
    Text("Settings")
        .presentationDestination(for: Settings.self) { settings in
            SettingsView(settings: settings)
                // All native presentation modifiers work
                .presentationCompactAdaptation(.fullScreenCover)
                .presentationDetents([.medium, .large])
                .presentationBackground(.regularMaterial)
                .presentationBackgroundInteraction(.enabled)
                .interactiveDismissDisabled()
                .presentationCornerRadius(20)
        }
}


// Navigation modifiers also supported
NavigationLink(value: user) {
    Text("User Detail")
        .presentationDestination(for: User.self) { user in
            UserDetailView(user: user)
                .navigationTransition(.zoom(sourceID: user.id, in: namespace))
                .toolbarRole(.editor)
        }
}
```

### Programmatic Navigation

```swift
struct UserDetailView: View {
    @Environment(\.presentation) private var router
    let user: User
    
    var body: some View {
        VStack {
            Text(user.name)
            
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

### Direct Path Manipulation

```swift
@State private var path = PresentationPath()

// Navigate programmatically
path.append(User(id: 1))
path.present(SettingsData(), over: .root)

// Go back
path.removeLast() // Removes last item or dismisses sheet

// Namespace-specific navigation
path.removeLast(from: .child(someKey))
```

### Multiple Destination Types

```swift
PresentationStack(path: $path) {
    // Your content
}
.presentationDestination(for: User.self) { user in
    UserDetailView(user: user)
}
.presentationDestination(for: Document.self) { document in
    DocumentViewer(document: document)
}
.presentationDestination(for: Settings.self) { settings in
    SettingsView(settings: settings)
}
```

## Installation

### Swift Package Manager

Add this package to your project through Xcode:

1. File → Add Package Dependencies
2. Enter: `https://github.com/stalkermv/SwiftUIPresentation`
3. Select version and add to your target

Or add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/stalkermv/SwiftUIPresentation", from: "1.0.0")
]
```

## Requirements

- iOS 17.0+ / macOS 14.0+
- Swift 6.0+
- Xcode 16.0+

## Documentation

Comprehensive documentation is available in the package. Use Xcode's built-in documentation viewer or build with DocC:

```bash
swift package generate-documentation
```

## Testing

Run the test suite:

```bash
swift test
```

The library includes comprehensive unit tests covering:
- Navigation state management
- Namespace isolation
- Router functionality  
- Edge cases and error conditions

## Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## License

SwiftUIPresentation is available under the MIT license. See [LICENSE](LICENSE) for details.

## Authors

Created by [Valeriy Malishevskyi](https://github.com/stalkermv)

---

*Built with ❤️ for the SwiftUI community*
