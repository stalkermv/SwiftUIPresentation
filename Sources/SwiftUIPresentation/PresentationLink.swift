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
/// or by presenting a modal sheet using the `method` parameter.
/// By default, presentation links show content as sheets unless explicitly 
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
///         // Default sheet presentation
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
///             .presentationAdaptation(.fullScreenCover)
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
/// ### Show sheets for quick actions
/// Use sheet presentation for temporary content that doesn't require deep
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
    
    /// The style of navigation to perform.
    public enum PresentationType {
        /// Shows the destination modally, layered over current content.
        case sheet
        /// Pushes the destination onto the navigation stack.
        case stack
    }
    
    @Environment(\.presentation) private var presentation
    
    private let value: Value
    private let method: PresentationType
    private let label: () -> Label
    
    /// Creates a link that presents the supplied value.
    /// - Parameters:
    ///   - value: A hashable value identifying the destination.
    ///   - method: How to surface the destination. Defaults to ``PresentationType/sheet``.
    ///   - label: A view builder that creates the link’s visual representation.
    public init(
        value: Value,
        method: PresentationType = .sheet,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.value = value
        self.method = method
        self.label = label
    }
    
    public var body: some View {
        Button(action: { present() }) {
            label()
        }
        .disabled(presentation == nil)
    }
    
    private func present() {
        if method == .stack, let presentation {
            presentation.push(value: value)
        } else if let presentation {
            presentation.present(value: value)
        } else {
            fatalError("No PresentationStack found in the view hierarchy")
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
