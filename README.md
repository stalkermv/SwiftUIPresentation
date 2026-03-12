# SwiftUIPresentation

[![Tests](https://github.com/stalkermv/SwiftUIPresentation/actions/workflows/tests.yml/badge.svg)](https://github.com/stalkermv/SwiftUIPresentation/actions/workflows/tests.yml)
[![Swift 6.1+](https://img.shields.io/badge/Swift-6.1+-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/platform-iOS%2017%2B-lightgrey.svg)](https://developer.apple.com/ios/)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Unified SwiftUI navigation for iOS with stack and sheet flows backed by a single testable path.

- Register each destination type once with `presentationDestination(for:)`
- Present the same destination as a sheet, full-screen cover, popover, or stack push
- Navigate programmatically through `PresentationPath` or the environment `PresentationRouter`
- Keep nested sheet flows isolated with their own presentation namespace

## Installation

Add `SwiftUIPresentation` to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/stalkermv/SwiftUIPresentation.git", from: "1.0.0")
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

## Modal Adaptation

Keep one destination registration and choose the modal host in the destination itself:

```swift
.presentationDestination(for: User.self) { user in
    UserDetailsView(user: user)
        .presentationAdaptation(.fullScreenCover)
        .presentationDetents([.large])
}
```

For push navigation, use the same destination with a different trigger:

```swift
PresentationLink(value: user, method: .stack) {
    Text("Open details")
}
```

`presentationAdaptation(_:)` is honored on iOS 18 and later. Earlier runtimes
fall back to a standard sheet host.

## Programmatic Navigation

```swift
struct UserDetailsView: View {
    @Environment(\.presentation) private var presentation
    let user: User

    var body: some View {
        VStack {
            Text(user.name)

            Button("Show settings") {
                presentation?.present(value: SettingsRoute())
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

`SwiftUIPresentation` is documented for iOS 17 and later. A macOS host build is still kept healthy so package tests and DocC generation remain stable in CI.

## Release

Release tags follow plain semver without a `v` prefix, for example `1.0.0`.

`SwiftUIPresentation` is published as a source-only Swift Package. This
repository doesn't ship XCFramework or other binary artifacts.

The repository is being prepared for:

- `swift build` and `swift test` validation
- iOS compile checks
- DocC validation and GitHub Pages deployment
- source release automation on semver tags

## License

`SwiftUIPresentation` is available under the MIT license. See [LICENSE](LICENSE).
