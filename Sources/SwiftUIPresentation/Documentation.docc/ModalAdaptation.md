# Modal Adaptation

Choose how a destination should be hosted without changing the trigger.

## Overview

`SwiftUIPresentation` lets you keep one destination registration:

```swift
.presentationDestination(for: User.self) { user in
    UserProfile(user: user)
}
```

and decide later whether that destination should appear as a sheet, popover,
or full-screen cover.

## Set adaptation on the destination

Apply `presentationAdaptation(_:)` inside the destination builder:

```swift
.presentationDestination(for: User.self) { user in
    UserProfile(user: user)
        .presentationAdaptation(.fullScreenCover)
}
```

Now all modal presentations of `User` use a full-screen cover, while the call
site stays unchanged:

```swift
PresentationLink(value: user) {
    Text(user.name)
}
```

## Switch only the trigger

Use the same destination as a push when needed:

```swift
PresentationLink(value: user, method: .stack) {
    Text("Open details")
}
```

This keeps the destination definition stable while the trigger decides between
push and modal navigation.

## Runtime behavior

Modal adaptation is honored on iOS 18 and later. Earlier runtimes fall back to
a standard sheet host so the destination remains usable.
