# Contributing to SwiftUIPresentation

Thank you for your interest in contributing! Here's how you can help improve the project.

## Quick Start

1. **Fork the repository** on GitHub
2. **Clone your fork** locally
3. **Create a feature branch**: `git checkout -b feature-name`
4. **Make your changes** and add tests
5. **Run tests**: `swift test`
6. **Submit a pull request**

## Reporting Issues

Found a bug or have a feature request? [Create an issue](https://github.com/stalkermv/SwiftUIPresentation/issues/new) with:
- Clear description of the problem/request
- Code example (for bugs)
- Expected vs actual behavior
- Environment details (iOS/macOS version, Xcode version)

## Development

### Requirements
- macOS 14.0+
- Xcode 27.2+
- Swift 6.1+

### Building & Testing
```bash
# Build the package
swift build

# Build with complete strict-concurrency checking
swift build -Xswiftc -strict-concurrency=complete

# Run all tests
swift test

# Generate documentation
DOCS_DIR="$(mktemp -d)"
swift package --allow-writing-to-directory "$DOCS_DIR" \
  generate-documentation --target SwiftUIPresentation \
  --output-path "$DOCS_DIR" \
  --transform-for-static-hosting \
  --hosting-base-path SwiftUIPresentation

# Compile both supported Apple targets from a clean package checkout
xcodebuild -scheme SwiftUIPresentation \
  -destination "generic/platform=iOS Simulator" build
xcodebuild -scheme SwiftUIPresentation \
  -destination "generic/platform=macOS" build
```

### Code Guidelines
- Follow Swift API Design Guidelines
- Write clear, descriptive names
- Add tests for new functionality
- Update documentation for public APIs
- Keep changes focused and atomic

## Questions?

Feel free to open an issue for questions or start a discussion. We're here to help! 🎉
