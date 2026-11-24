# SwiftUIPresentation

[![Tests](https://github.com/stalkermv/SwiftUIPresentation/actions/workflows/tests.yml/badge.svg)](https://github.com/stalkermv/SwiftUIPresentation/actions/workflows/tests.yml)
[![Swift 6.1+](https://img.shields.io/badge/Swift-6.1+-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/platform-iOS%2017%2B%20%7C%20macOS%2014%2B%20%7C%20tvOS%2017%2B%20%7C%20watchOS%2010%2B-lightgrey.svg)](https://developer.apple.com/swift/)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Unified SwiftUI navigation for iOS, macOS, tvOS and watchOS with stack and modal flows backed by a single testable path.

- Register each destination type once with `presentationDestination(for:)`
- Present the same destination as a sheet, full-screen cover, popover, or stack push
- Navigate programmatically through `PresentationPath` or the environment `PresentationRouter`
- Keep nested sheet flows isolated with their own presentation namespace

## Installation

Add `SwiftUIPresentation` to your `Package.swift`:

2.0 is currently a pre-release, so the requirement has to name it; `from: "2.0.0"` does not resolve pre-releases.

```swift
dependencies: [
    .package(url: "https://github.com/stalkermv/SwiftUIPresentation.git", from: "2.0.0-beta.1")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: [
            .product(name: "SwiftUIPresentation", package: "SwiftUIPresentation")
        ]
    )
]
```

## Quick Start

```swift
import SwiftUI
import SwiftUIPresentation

struct User: Identifiable, Hashable {
    let id: UUID
    let name: String
}

struct ContentView: View {
    @State private var path = PresentationPath()
    let users: [User]

    var body: some View {
        PresentationStack(path: $path) {
            List(users) { user in
                PresentationLink(value: user) {
                    Text(user.name)
                }
            }
            .presentationDestination(for: User.self) { user in
                UserDetailsView(user: user)
            }
        }
    }
}
```

## Modal Host Selection

Keep one destination registration and choose the modal host in the destination itself:

```swift
.presentationDestination(for: User.self) { user in
    UserDetailsView(user: user)
        .presentationHost(.fullScreenCover)
        .presentationDetents([.large])
}
```

`presentationHost(_:)` selects the modal host for a destination. On iOS 18 and
macOS 15 or later, `.sheet`, `.popover`, and (on iOS) `.fullScreenCover` are
available. On tvOS and watchOS every modal host is a sheet, because there is no
popover and a full-screen cover would not differ from a sheet. On iOS 17 and
macOS 14, modal destinations use a standard sheet so the same flow remains
usable.

For push navigation, use the same destination with a different trigger:

```swift
PresentationLink(value: user, method: .stack) {
    Text("Open details")
}
```

The deprecated `presentationAdaptation(_:)` method is retained only as a
compatibility wrapper for SwiftUI's compact-size-class adaptation. It does not
select the modal host; use `presentationHost(_:)` for that.

## Programmatic Navigation

```swift
struct UserDetailsView: View {
    @Environment(\.presentation) private var presentation
    let user: User

    var body: some View {
        VStack {
            Text(user.name)

            Button("Show settings") {
                presentation?.present(SettingsRoute())
            }

            Button("Go back") {
                presentation?.pop()
            }
        }
    }
}
```

You can also mutate the path directly:

```swift
path.append(user)
path.present(SettingsRoute(), over: .root)
path.removeLast()
```

## Documentation

DocC documentation lives in the package and can be browsed in Xcode or built locally:

```bash
swift package --allow-writing-to-directory ./docs \
  generate-documentation --target SwiftUIPresentation \
  --output-path ./docs \
  --transform-for-static-hosting \
  --hosting-base-path SwiftUIPresentation
```

## Development

Run the package tests:

```bash
swift test
```

`SwiftUIPresentation` supports iOS 17+, macOS 14+, tvOS 17+ and watchOS 10+. CI
compiles all four Apple platforms in addition to running the host tests and
DocC generation.

The public-state and compatibility guarantees are summarized in
[API_CONTRACT.md](API_CONTRACT.md).

## Release

Release tags follow plain semver without a `v` prefix, for example `1.0.0`.

`SwiftUIPresentation` is published as a source-only Swift Package. This
repository doesn't ship XCFramework or other binary artifacts.

The repository is being prepared for:

- `swift build` and `swift test` validation
- iOS and macOS compile checks
- DocC validation and GitHub Pages deployment
- source release automation on semver tags

## License

`SwiftUIPresentation` is available under the MIT license. See [LICENSE](LICENSE).
