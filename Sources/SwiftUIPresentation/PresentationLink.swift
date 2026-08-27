//
//  PresentationLink.swift
//  SwiftUIPresentation
//
//  Created by Valeriy Malishevskyi on 05.09.2025.
//

import SwiftUI

/// The navigation operation performed by a ``PresentationLink``.
public enum PresentationMethod: Hashable, Sendable {
    /// Presents the destination modally.
    case sheet
    /// Pushes the destination onto the current navigation stack.
    case stack
}

/// A view that triggers navigation when people interact with it.
///
/// People tap or click a presentation link to navigate to additional content.
/// You control whether navigation happens by pushing onto the current stack
/// or by presenting a modal using the `method` parameter.
/// By default, presentation links show content modally unless explicitly
/// configured otherwise.
///
/// ### Navigate with values
/// First, declare what view to show for each data type using
/// `presentationDestination(for:destination:)`. Then create
/// links that present specific values:
///
/// ```swift
/// PresentationStack {
///     List(users) { user in
///         // Default modal presentation
///         PresentationLink(value: user) {
///             Label(user.name, systemImage: "person")
///         }
///         
///         // Explicit stack navigation  
///         PresentationLink(value: user, method: .stack) {
///             Label("Details", systemImage: "arrow.right")
///         }
///         
///         // You can also use native NavigationLink for stack navigation
///         NavigationLink(value: user) {
///             Label("Navigate", systemImage: "chevron.right")
///         }
///     }
///     .presentationDestination(for: User.self) { user in
///         UserDetail(user: user)
///             .presentationHost(.fullScreenCover)
///             .presentationDetents([.medium, .large])
///     }
/// }
/// ```
///
/// ```swift
/// PresentationStack {
///     List(users) { user in
///         PresentationLink(value: user, method: .stack) {
///             Label(user.name, systemImage: "person")
///         }
///     }
///     .presentationDestination(for: User.self) { user in
///         UserDetail(user: user)
///     }
/// }
/// ```
///
/// ### Show modals for quick actions
/// Use modal presentation for temporary content that doesn't require deep
/// navigation:
///
/// ```swift
/// PresentationLink(value: user, method: .sheet) {
///     Text("Quick Edit")
/// }
/// ```
///
/// The link becomes disabled automatically when no ``PresentationStack``
/// is present in the view hierarchy.
public struct PresentationLink<Value: Hashable, Label: View>: View {

    /// The legacy name for ``PresentationMethod``.
    @available(*, deprecated, renamed: "PresentationMethod")
    public typealias PresentationType = PresentationMethod
    
    @Environment(\.presentation) private var presentation
    
    private let value: Value
    private let method: PresentationMethod
    private let label: Label

    /// Creates a link that presents the supplied value.
    /// - Parameters:
    ///   - value: A hashable value identifying the destination.
    ///   - method: How to surface the destination. Defaults to ``PresentationMethod/sheet``.
    ///   - label: A view builder that creates the link’s visual representation.
    public init(
        value: Value,
        method: PresentationMethod = .sheet,
        @ViewBuilder label: () -> Label
    ) {
        self.value = value
        self.method = method
        self.label = label()
    }

    /// Creates a link using the legacy `presentationType` label.
    ///
    /// Prefer ``init(value:method:label:)`` in new code.
    @available(*, deprecated, message: "Use init(value:method:label:) instead.")
    public init(
        value: Value,
        presentationType: PresentationMethod,
        @ViewBuilder label: () -> Label
    ) {
        self.init(value: value, method: presentationType, label: label)
    }

    public var body: some View {
        Button(action: { present() }) {
            label
        }
        .disabled(presentation == nil)
    }

    private func present() {
        guard let presentation else { return }
        if method == .stack {
            presentation.push(value)
        } else {
            presentation.present(value)
        }
    }
}
