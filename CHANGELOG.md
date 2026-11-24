# Changelog

All notable changes to SwiftUIPresentation will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- `PresentationRouter.isPresentingModal` (the previous meaning of `isPresented`) and `PresentationRouter.isInModal`, which is `true` when the router's stack is itself shown in a modal

### Deprecated
- `PresentationRouter.isPresented`; use `isPresentingModal` for "something is shown on top of this stack" or `isInModal` for "this stack is shown in a modal"

### Documentation
- Destinations are registered per stack: inside an embedded sheet stack, repeat `presentationDestination` before `embedInPresentation()`. The environment router read in a destination belongs to the parent stack

## [2.0.0-beta.1] - 2026-11-24

### Added
- Documentation rewrite for the public API and DocC guides
- GitHub Actions workflows for tests, documentation, and releases
- `PresentationMethod` and `PresentationHost` value types for explicit
  navigation and modal-host selection
- Namespace-based `PresentationPath.dismiss(in:)` and canonical empty-path
  behavior

### Changed
- Presentation identities are UUID-backed, so equal values no longer reuse
  nested presentation state
- `PresentationRouter` is main-actor isolated and now uses Swift-style
  `push(_:)` and `present(_:)` methods
- Replacing or dismissing a modal recursively removes all descendant
  namespaces, and presented destinations receive a fresh SwiftUI identity
- `presentationAdaptation(_:)` is deprecated as a host selector and now
  forwards to SwiftUI's compact-size-class adaptation; use `presentationHost(_:)`
  to choose a host

### Breaking
- The unfinished `PresentationLink(isPresented:label:)` initializer was
  removed; it always terminated at runtime and had no destination value
- `PresentationPath` no longer claims `Sendable` because it stores SwiftUI
  navigation state and type-erased values
- Depends on SwiftUIHelpers `from: "2.0.0-beta.2"` (a pre-release)

### Platforms
- Supported platforms are iOS 17+, macOS 14+, tvOS 17+ and watchOS 10+; the
  package builds for all four
- On tvOS and watchOS every modal host is a sheet, because there is no popover
  there and a full-screen cover would not differ from a sheet
- CI runs on Xcode 27.2 and compiles for iOS, macOS, tvOS and watchOS

## [1.0.0] - 2026-03-12

### Added
- Initial public release of SwiftUIPresentation
- `PresentationStack` for unified stack and modal navigation
- `PresentationLink` for value-driven push or modal presentation
- `PresentationPath` for testable navigation state
- `PresentationRouter` for environment-driven navigation
- Destination-level modal adaptation with stable `PresentationLink(value:)` call sites
- DocC guides for getting started, modal adaptation, concepts, and programmatic navigation
- GitHub Actions workflows for Swift tests, DocC build checks, Pages deployment, and releases

### Dependencies
- SwiftUIHelpers for internal utilities
- Swift Testing framework for unit tests

### Documentation
- README aligned with the published public API
- Apple-style DocC articles with examples and release-ready reference docs
