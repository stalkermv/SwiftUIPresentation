# ``SwiftUIPresentation``

Create iOS and macOS navigation flows that combine stack pushes and modal presentations
without splitting state across multiple APIs.

## Overview

`SwiftUIPresentation` simplifies complex navigation by letting you describe
*what* to show (data → view mappings) separately from *how* to show it (push
vs sheet). A single ``PresentationPath`` tracks navigation state across
multiple contexts, making your navigation logic easier to test and maintain.

### How it works

1. Wrap your content in a ``PresentationStack``
2. Use `presentationDestination(for:destination:)` to map data types to views
3. Trigger navigation with ``PresentationLink`` or the environment ``PresentationRouter``
4. Optionally set `presentationHost(_:)` on the destination to choose the modal host

```swift
@State private var path = PresentationPath()

PresentationStack(path: $path) {
    List(users) { user in
        // Default sheet presentation
        PresentationLink(value: user) {
            Text(user.name)
        }
        
        // Explicit stack navigation
        PresentationLink(value: user, method: .stack) {
            Text("Navigate")
        }
    }
    .presentationDestination(for: User.self) { user in
        UserProfile(user: user)
            .presentationHost(.fullScreenCover)
    }
}
```

### Benefits

* **Unified state**: One path manages both stack pushes and sheet presentations
* **Destination reuse**: Register a destination once and reuse it for different presentation styles
* **Modal host selection**: Keep `PresentationLink(value:)` unchanged and choose the host from the destination
* **Default sheet behavior**: Present values with a single link by default
* **Nested flows**: Sheets automatically get isolated navigation contexts
* **Testable navigation**: Programmatic control through value-based APIs
* **Namespace isolation**: Each navigation context maintains independent state

### Navigation control

Navigate forward and backward with clear, predictable methods:

```swift
@Environment(\.presentation) private var router

// Navigate forward
router?.push(user)        // Add to stack
router?.present(settings) // Show as sheet

// Navigate backward
router?.pop()      // Remove last stack item or dismiss sheet
router?.dismiss()  // Dismiss sheet only
```

### When to use

Choose `SwiftUIPresentation` when you need to mix hierarchical navigation
with modal presentations, especially if you want programmatic control over
navigation state.

For simple, static navigation hierarchies, SwiftUI's built-in `NavigationStack`
and `NavigationLink` are sufficient.

## Topics

### Essentials
- ``PresentationStack``
- ``PresentationLink``
- ``PresentationMethod``
- ``PresentationPath``
- ``PresentationRouter``

### Modal hosts
- ``PresentationHost``

### Namespaces
- ``PresentationStackNamespace``

### Guides
- <doc:GettingStarted>
- <doc:ModalAdaptation>
- <doc:ProgrammaticNavigation>
- <doc:Concepts>

### Diagnostics
- ``PresentationPath/debugDescription``
- ``PresentationRouter/isPresentingModal``
- ``PresentationRouter/isInModal``
