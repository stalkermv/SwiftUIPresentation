//
//  PresentationLink.swift
//  SwiftUIPresentation
//
//  Created by Valeriy Malishevskyi on 05.09.2025.
//

import SwiftUI

/// A view that triggers navigation when people interact with it.
///
/// People tap or click a presentation link to navigate to additional content.
/// You control whether navigation happens by pushing onto the current stack
/// or by presenting a modal sheet using the `presentationType` parameter.
/// By default, presentation links show content as sheets unless explicitly 
/// configured otherwise.
///
/// ### Navigate with values
/// First, declare what view to show for each data type using
/// ``SwiftUIPresentation/SwiftUICore/View/presentationDestination(for:destination:)``. Then create
/// links that present specific values:
///
/// ```swift
/// PresentationStack {
///     List(users) { user in
///         // Default sheet presentation
///         PresentationLink(value: user) {
///             Label(user.name, systemImage: "person")
///         }
///         
///         // Explicit stack navigation  
///         PresentationLink(value: user, presentationType: .stack) {
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
///             // All native SwiftUI presentation modifiers work
///             .presentationDetents([.medium, .large])
///             .presentationCompactAdaptation(.fullScreenCover)
///             .interactiveDismissDisabled()
///     }
/// }
/// ```
///
/// ```swift
/// PresentationStack {
///     List(users) { user in
///         PresentationLink(value: user, presentationType: .stack) {
///             Label(user.name, systemImage: "person")
///         }
///     }
///     .presentationDestination(for: User.self) { user in
///         UserDetail(user: user)
///     }
/// }
/// ```
///
/// ### Show sheets for quick actions
/// Use sheet presentation for temporary content that doesn't require deep
/// navigation:
///
/// ```swift
/// PresentationLink(value: user, presentationType: .sheet) {
///     Text("Quick Edit")
/// }
/// ```
///
/// The link becomes disabled automatically when no ``PresentationStack``
/// is present in the view hierarchy.
public struct PresentationLink<Value: Hashable, Label: View>: View {
    
    /// The style of navigation to perform.
    public enum PresentationType {
        /// Shows the destination modally, layered over current content.
        case sheet
        /// Pushes the destination onto the navigation stack.
        case stack
    }
    
    @Environment(\.presentation) private var presentation
    
    private let value: Value
    private let presentationType: PresentationType
    private let label: () -> Label
    
    /// Creates a link that presents the supplied value.
    /// - Parameters:
    ///   - value: A hashable value identifying the destination.
    ///   - presentationType: How to surface the destination. Defaults to ``PresentationType/sheet``.
    ///   - label: A view builder that creates the link’s visual representation.
    public init(
        value: Value,
        presentationType: PresentationType = .sheet,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.value = value
        self.presentationType = presentationType
        self.label = label
    }
    
    public var body: some View {
        Button(action: { present() }) {
            label()
        }
        .disabled(presentation == nil)
    }
    
    private func present() {
        if presentationType == .stack {
            presentation?.push(value: value)
        } else {
            presentation?.present(value: value)
        }
    }
}

extension PresentationLink {
    
    /// Creates a link that's controlled by a Boolean binding.
    ///
    /// This initializer isn't implemented yet. Use the value-based initializer
    /// instead. Calling this initializer causes your app to terminate with
    /// a runtime error.
    public init(isPresented: Binding<Bool>, @ViewBuilder label: @escaping () -> Label) {
        // MARK TODO: - Using UUID as a value to ensure uniqueness
        fatalError("Not implemented yet")
    }
}
