# Concepts

Understand the key ideas behind SwiftUIPresentation.

## Presentation Path

A ``PresentationPath`` is like SwiftUI's `NavigationPath`, but it also tracks
modal sheets. Each "namespace" has its own stack of pushed items plus an
optional sheet item.

```swift
// Add to the stack
path.append(user)

// Show a sheet (replaces any existing sheet)
path.present(settings, over: .root)

// Go back (pops from stack, or dismisses sheet if stack is empty)
path.removeLast()
```

## Namespaces

When you show a sheet, it automatically gets its own navigation context (child
namespace). This means navigation inside the sheet doesn't interfere with the
navigation that's underneath it.

```
Root namespace: [Home, UserList]
  └─ Sheet shows Settings
       └─ Settings namespace: [General, Privacy]
```

## Destination Registration

Instead of embedding view creation in your navigation triggers, you register
destinations once and navigate by presenting values:

```swift
// Register what to show for each type
.presentationDestination(for: User.self) { user in
    UserProfile(user: user)
        .presentationAdaptation(.fullScreenCover)
}

// Navigate by presenting values
PresentationLink(value: selectedUser) { ... }
PresentationLink(value: selectedUser, method: .stack) { ... }
```

## Environment Router

The ``PresentationRouter`` is available through the environment, letting any
view trigger navigation without prop drilling:

```swift
@Environment(\.presentation) private var router

Button("Settings") {
    router?.present(value: SettingsData())
}
```

## Testing and Debugging

Since ``PresentationPath`` uses value semantics, you can easily test navigation
logic without rendering views. Use ``PresentationPath/debugDescription`` to
inspect the current state during development.
