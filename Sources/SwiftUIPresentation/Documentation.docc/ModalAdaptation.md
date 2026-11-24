# Modal Host Selection

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

## Set the host on the destination

Apply `presentationHost(_:)` inside the destination builder:

```swift
.presentationDestination(for: User.self) { user in
    UserProfile(user: user)
        .presentationHost(.fullScreenCover)
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

Host selection is honored on iOS 18 and macOS 15 or later. On iOS 17 and macOS
14, destinations use a standard sheet host so the flow remains usable. The
deprecated `presentationAdaptation(_:)` method is only a compatibility wrapper
for SwiftUI's compact-size-class adaptation; it is not a host selector.

On tvOS and watchOS every modal host is a sheet: there is no popover, and a
full-screen cover would not differ from a sheet.
