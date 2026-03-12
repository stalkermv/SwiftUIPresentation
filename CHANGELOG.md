# Changelog

All notable changes to SwiftUIPresentation will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Documentation rewrite for the public API and DocC guides
- GitHub Actions workflows for tests, documentation, and releases

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
