# SwiftUIPresentation API contract

This document describes the supported behavior of the package and the
intentional API cleanup planned for the next release.

## State model

`PresentationPath` is the single source of truth for a presentation stack.
Each `PresentationStackNamespace` contains an ordered `NavigationPath` and at
most one presented item.

- `append(_:namespace:)` pushes a `Hashable` value.
- `present(_:over:)` replaces the current modal item in that namespace.
- Every modal item receives an opaque, UUID-backed identity independent of its
  value. Presenting an equal value therefore creates a new presentation
  instance.
- Replacing or dismissing an item removes its complete descendant namespace
  tree. Nested sheets never retain navigation state after their parent is
  dismissed.
- `dismiss(in:)` is the exact namespace-based dismissal API. It dismisses the
  local item first; when a child namespace has no local item, it dismisses the
  sheet that owns that child.
- Empty containers are removed from storage, so an empty path remains
  canonical and compares equal to `PresentationPath()`.

The value requirement is deliberately `Hashable`, matching SwiftUI's
`NavigationPath` and allowing one registry to handle heterogeneous routes.
`PresentationPath` is UI state and is not `Sendable`; keep it on the actor that
owns the view state. `PresentationRouter` is `@MainActor` and should be used
from the main actor.

## Canonical public surface

Use these spellings in new code:

```swift
PresentationLink(value: route, method: .sheet) {
    Text("Open")
}

router?.push(route)
router?.present(settings)
router?.pop()
router?.dismiss()
```

`PresentationLink` defaults to `.sheet`; use `.stack` for a push. The
environment router is optional and links are disabled when no
`PresentationStack` is in the hierarchy.

To select a modal host from a destination, use:

```swift
.presentationHost(.sheet)
.presentationHost(.popover)
.presentationHost(.fullScreenCover)
```

`.fullScreenCover` is available as a host on iOS. On macOS it falls back to a
sheet. Host selection is available on iOS 18/macOS 15 and later; older runtimes
use a standard sheet host. The package manifest declares iOS 17+ and macOS 14+;
tvOS and watchOS are outside the supported platform contract.

## Compatibility and migration

The following 1.x spellings remain available but are deprecated:

- `PresentationRouter.push(value:)` → `push(_:)`
- `PresentationRouter.present(value:)` → `present(_:)`
- `PresentationLink.PresentationType` → `PresentationMethod`
- `PresentationLink(value:presentationType:label:)` →
  `PresentationLink(value:method:label:)`
- `PresentationPath.dismiss(presenting:)` → `dismiss(in:)`
- `View.presentationAdaptation(_:)` → `presentationHost(_:)` for host
  selection. The compatibility method now forwards to SwiftUI's native
  compact-size-class adaptation and no longer selects a host.

The Boolean `PresentationLink(isPresented:label:)` initializer was removed
because its 1.0 implementation always terminated at runtime and had no
destination value to register. Use a value-based link or `PresentationPath`
instead.

Because the cleanup removes that initializer and the unsound `Sendable`
conformance from `PresentationPath`, the next tagged release should be a
major version (2.0.0). No release or push is implied by this document.
