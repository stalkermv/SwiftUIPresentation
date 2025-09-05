# Changelog

All notable changes to SwiftUIPresentation will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial public release
- `PresentationStack` - Main container for unified navigation
- `PresentationLink` - UI component for triggering navigation
- `PresentationPath` - Value type for managing navigation state
- `PresentationRouter` - Environment-injected navigation controller
- Support for both stack (push) and sheet (modal) presentation
- Namespace isolation for nested navigation contexts
- Comprehensive test suite with 20+ unit tests
- Complete DocC documentation with guides and examples

### Technical Details
- Swift 6.0+ support with full concurrency safety
- iOS 17.0+ and macOS 14.0+ compatibility
- Type-safe destination mapping
- Programmatic navigation APIs
- Backward-compatible API design

## [1.0.0] - 2025-09-09

### Added
- Initial release of SwiftUIPresentation
- Full feature set as described above

### Dependencies
- SwiftUIHelpers for internal utilities
- Swift Testing framework for unit tests

### Documentation
- Getting Started guide
- Concepts documentation
- Complete API reference
- Usage examples and best practices
