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
/// ### Navigate from any view
/// ```swift
/// struct DetailView: View {
///     @Environment(\.presentation) private var router
///
///     var body: some View {
///         VStack {
///             Button("Show Settings") {
///                 router?.present(value: SettingsData())
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
public struct PresentationRouter: @unchecked Sendable {
    let namespace: PresentationStackNamespace
    @Binding var presentationPath: PresentationPath
    
    /// Adds a value to the navigation stack.
    ///
    /// The new value becomes the top item on the stack and triggers navigation
    /// to the registered destination for its type.
    public func push<Value>(value: Value) where Value : Hashable {
        presentationPath.append(value, namespace: namespace)
    }
    
    /// Shows a value in a sheet.
    ///
    /// The sheet displays the registered destination for the value's type.
    /// If a sheet is already showing, this method replaces it with the new value.
    public func present<Value>(value: Value) where Value : Hashable {
        presentationPath.present(value, over: namespace)
    }
    
    /// Removes the most recent navigation change in this router's namespace.
    ///
    /// If the namespace stack has items, this method removes the top item. If the
    /// stack is empty but a sheet is showing, this method dismisses the sheet.
    /// If both the stack and sheet are empty, this method does nothing.
    public func pop() {
        presentationPath.removeLast(from: namespace)
    }
    
    /// Dismisses the presented sheet in this router's namespace.
    ///
    /// If no sheet is currently showing, this method does nothing.
    /// When called from inside a sheet (child namespace), dismisses the sheet
    /// that hosts the current view.
    public func dismiss() {
        switch namespace {
        case .root:
            mutatePath { $0.clearPresentedItem(in: .root) }
        case .child(let key):
            mutatePath { $0.dismiss(presenting: key.key) }
        }
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
