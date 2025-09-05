# ``SwiftUIPresentation``

Create navigation experiences that seamlessly combine stack navigation
and modal sheets.

## Overview

`SwiftUIPresentation` simplifies complex navigation by letting you describe
*what* to show (data → view mappings) separately from *how* to show it (push
vs sheet). A single ``PresentationPath`` tracks navigation state across
multiple contexts, making your navigation logic easier to test and maintain.

### How it works

1. Wrap your content in a ``PresentationStack``
2. Use ``SwiftUIPresentation/SwiftUICore/View/presentationDestination(for:destination:)`` to map data types to views
3. Navigate with ``PresentationLink`` or the environment ``PresentationRouter``

```swift
@State private var path = PresentationPath()

PresentationStack(path: $path) {
    List(users) { user in
        // Default sheet presentation
        PresentationLink(value: user) {
            Text(user.name)
        }
        
        // Explicit stack navigation
        NavigationLink(value: user) {
            Text("Navigate →")
        }
    }
    .presentationDestination(for: User.self) { user in
        UserProfile(user: user)
            // All native SwiftUI modifiers work
            .presentationDetents([.medium, .large])
            .interactiveDismissDisabled()
    }
}
```

### Benefits

* **Unified state**: One path manages both stack pushes and sheet presentations
* **Native integration**: Full compatibility with SwiftUI navigation and presentation modifiers
* **Flexible presentation**: Switch between stack and sheet with one parameter
* **Default sheet behavior**: Simple API with sensible defaults
* **Nested flows**: Sheets automatically get isolated navigation contexts
* **Testable navigation**: Programmatic control through value-based APIs
* **Namespace isolation**: Each navigation context maintains independent state

### Navigation control

Navigate forward and backward with clear, predictable methods:

```swift
@Environment(\.presentation) private var router

// Navigate forward
router?.push(value: user)        // Add to stack
router?.present(value: settings) // Show as sheet

// Navigate backward
router?.pop()      // Remove last stack item or dismiss sheet
router?.dismiss()  // Dismiss sheet only
```

### When to use

Choose `SwiftUIPresentation` when you need to mix hierarchical navigation
with modal presentations, especially if you want programmatic control over
navigation state.

For simple, static navigation hierarchies, SwiftUI's built-in `NavigationStack`
and `NavigationLink` are sufficient.## Topics

### Essentials
- ``PresentationStack``
- ``PresentationLink``
- ``PresentationPath``
- ``PresentationRouter``

### Destinations
- ``SwiftUIPresentation/SwiftUICore/View/presentationDestination(for:destination:)``

### Namespaces
- ``PresentationStackNamespace``

### Guides
- <doc:GettingStarted>
- <doc:Concepts>

### Diagnostics
- ``PresentationPath/debugDescription``
