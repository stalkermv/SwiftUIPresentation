//
//  PresentationRouter.swift
//  SwiftUIPresentation
//
//  Created by Valeriy Malishevskyi on 05.09.2025.
//

import SwiftUI

/// An object that provides navigation methods to views in the environment.
///
/// A presentation router lets any view trigger navigation without needing
/// direct access to the presentation path. ``PresentationStack`` automatically
/// provides a router through the environment.
///
/// The router is `@MainActor` because it mutates SwiftUI view state.
///
/// ### Navigate from any view
/// ```swift
/// struct DetailView: View {
///     @Environment(\.presentation) private var router
///
///     var body: some View {
///         VStack {
///             Button("Show Settings") {
///                 router?.present(SettingsData())
///             }
///             
///             Button("Go Back") {
///                 router?.pop()
///             }
///             
///             Button("Dismiss Modal") {
///                 router?.dismiss()
///             }
///         }
///     }
/// }
/// ```
@MainActor
public struct PresentationRouter {
    let namespace: PresentationStackNamespace
    @Binding var presentationPath: PresentationPath
    
    /// Adds a value to the navigation stack.
    ///
    /// The new value becomes the top item on the stack and triggers navigation
    /// to the registered destination for its type.
    public func push<Value>(_ value: Value) where Value : Hashable {
        presentationPath.append(value, namespace: namespace)
    }

    /// Adds a value to the navigation stack.
    ///
    /// - Note: This spelling is retained for source compatibility. Prefer
    ///   ``push(_:)`` in new code.
    @available(*, deprecated, message: "Use push(_:) instead.")
    public func push<Value>(value: Value) where Value : Hashable {
        push(value)
    }
    
    /// Shows a value as a modal destination.
    ///
    /// The modal displays the registered destination for the value's type.
    /// If a modal is already showing, this method replaces it with the new value.
    public func present<Value>(_ value: Value) where Value : Hashable {
        presentationPath.present(value, over: namespace)
    }

    /// Shows a value as a modal destination.
    ///
    /// - Note: This spelling is retained for source compatibility. Prefer
    ///   ``present(_:)`` in new code.
    @available(*, deprecated, message: "Use present(_:) instead.")
    public func present<Value>(value: Value) where Value : Hashable {
        present(value)
    }
    
    /// Removes the most recent navigation change in this router's namespace.
    ///
    /// If the namespace stack has items, this method removes the top item. If the
    /// stack is empty but a modal is showing, this method dismisses the modal.
    /// If both the stack and sheet are empty, this method does nothing.
    public func pop() {
        presentationPath.removeLast(from: namespace)
    }
    
    /// Dismisses the presented modal in this router's namespace.
    ///
    /// If no modal is currently showing, this method does nothing.
    /// When called from inside a modal (child namespace), dismisses that
    /// namespace's local modal first; if it has no local modal, dismisses the
    /// modal that hosts the current view.
    public func dismiss() {
        mutatePath { $0.dismiss(in: namespace) }
    }
    
    /// A Boolean value that indicates whether this router's namespace currently
    /// presents a modal destination.
    public var isPresented: Bool {
        presentationPath.isPresented(in: namespace)
    }

    private func mutatePath(_ body: (inout PresentationPath) -> Void) {
        var path = presentationPath
        body(&path)
        presentationPath = path
    }
}
