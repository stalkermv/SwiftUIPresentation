//
//  PresentationPath.swift
//  SwiftUIPresentation
//
//  Created by Valeriy Malishevskyi on 05.09.2025.
//

import Foundation
import SwiftUI

/// A value that tracks navigation stacks and optional modal items across
/// presentation namespaces.
///
/// A presentation path drives both hierarchical (push) and contextual (modal)
/// presentation. Each namespace maintains its own ordered stack plus at most
/// one presented modal item. Mutating methods provide clear, testable semantics.
///
/// ### Programmatic control
/// Update the path directly or through a ``PresentationRouter``:
/// ```swift
/// path.append(user)
/// path.present(settings, over: .root)
/// path.removeLast() // Pops last element or dismisses the modal if stack is empty.
/// ```
///
/// ### Namespaces
/// Modals create child namespaces so navigation inside a modal doesn’t leak
/// into the root stack.
///
/// `PresentationPath` is UI state backed by SwiftUI's `NavigationPath` and is
/// intentionally not `Sendable`. Mutate it on the actor that owns the view
/// state (normally the main actor).
public struct PresentationPath: Equatable {

    // MARK: - Internal Types

    internal struct PresentationItem: Identifiable, Hashable {
        let id: PresentationStackKey
        let value: AnyHashable

        init<T: Hashable>(_ value: T) {
            self.id = PresentationStackKey()
            self.value = AnyHashable(value)
        }
    }

    internal struct PresentationContainer: Equatable {
        var path: NavigationPath
        var item: PresentationItem?

        init(_ path: NavigationPath = NavigationPath(), item: PresentationItem? = nil) {
            self.path = path
            self.item = item
        }
    }

    // MARK: - Storage

    var stack: [PresentationStackNamespace: PresentationContainer] = [:]

    /// A Boolean value that indicates whether every presentation namespace is
    /// empty.
    public var isEmpty: Bool {
        stack.values.allSatisfy { $0.path.isEmpty && $0.item == nil }
    }

    /// Adds a value to the navigation stack for the specified namespace.
    ///
    /// The new value becomes the top item on the stack. If no stack exists
    /// for this namespace, this method creates one.
    public mutating func append<T: Hashable>(
        _ element: T,
        namespace: PresentationStackNamespace = .root
    ) {
        var container = stack[namespace, default: PresentationContainer()]
        container.path.append(element)
        store(container, in: namespace)
    }
    
    /// Shows a value as a modal destination for the specified namespace.
    ///
    /// If a modal is already showing for this namespace, this method replaces it
    /// with the new value.
    public mutating func present<T: Hashable>(
        _ element: T,
        over namespace: PresentationStackNamespace = .root
    ) {
        var container = stack[namespace, default: PresentationContainer()]
        if let previousItem = container.item {
            removeNamespaceTree(for: previousItem.id)
        }
        container.item = PresentationItem(element)
        store(container, in: namespace)
    }
    
    /// Clears the presented item in the given namespace after a UI dismissal.
    ///
    /// The item's complete descendant namespace tree is removed so the next
    /// presentation starts with a fresh navigation stack.
    internal mutating func clearPresentedItem(in namespace: PresentationStackNamespace) {
        guard var container = stack[namespace], let item = container.item else { return }
        container.item = nil
        store(container, in: namespace)
        removeNamespaceTree(for: item.id)
    }

    /// Dismisses the presented modal in a namespace.
    ///
    /// It dismisses a local item first. If a child namespace has no local item,
    /// it dismisses the modal that owns that child namespace. Dismissing also
    /// removes all nested presentation state below the dismissed item.
    public mutating func dismiss(in namespace: PresentationStackNamespace = .root) {
        switch namespace {
        case .root:
            clearPresentedItem(in: .root)
        case .child(let key):
            if stack[namespace]?.item != nil {
                clearPresentedItem(in: namespace)
            } else {
                dismiss(presenting: key)
            }
        }
    }

    /// Dismisses the modal that is currently presenting the given value.
    ///
    /// - Important: Values are not guaranteed to be unique. Prefer
    ///   ``dismiss(in:)`` when the namespace is known.
    @available(*, deprecated, message: "Use dismiss(in:) to dismiss by presentation namespace.")
    public mutating func dismiss(presenting value: AnyHashable) {
        guard let match = stack.first(where: { $0.value.item?.value == value }) else { return }
        clearPresentedItem(in: match.key)
    }

    internal mutating func dismiss(presenting key: PresentationStackKey) {
        guard let match = stack.first(where: { $0.value.item?.id == key }) else { return }
        clearPresentedItem(in: match.key)
    }

    /// Returns whether the namespace currently presents a modal item.
    public func isPresented(in namespace: PresentationStackNamespace) -> Bool {
        stack[namespace]?.item != nil
    }

    /// Removes the most recent navigation change in the specified namespace.
    ///
    /// If the namespace stack has items, this method removes the top item. If the
    /// stack is empty but a modal is showing, this method dismisses the modal.
    /// If both the stack and modal are empty, this method does nothing.
    public mutating func removeLast(from namespace: PresentationStackNamespace = .root) {
        guard var container = stack[namespace] else {
            if case .child(let key) = namespace {
                dismiss(presenting: key)
            }
            return
        }

        if !container.path.isEmpty {
            container.path.removeLast()
            store(container, in: namespace)
        } else if container.item != nil {
            clearPresentedItem(in: namespace)
        } else if case .child(let key) = namespace {
            dismiss(presenting: key)
        }
    }

    // MARK: - Private Helpers

    private mutating func store(
        _ container: PresentationContainer,
        in namespace: PresentationStackNamespace
    ) {
        if container.path.isEmpty && container.item == nil {
            stack.removeValue(forKey: namespace)
        } else {
            stack[namespace] = container
        }
    }

    internal mutating func setNavigationPath(
        _ navigationPath: NavigationPath,
        in namespace: PresentationStackNamespace
    ) {
        var container = stack[namespace, default: PresentationContainer()]
        container.path = navigationPath
        store(container, in: namespace)
    }

    private mutating func removeNamespaceTree(for key: PresentationStackKey) {
        guard let child = stack.removeValue(forKey: .child(key)) else { return }
        if let item = child.item {
            removeNamespaceTree(for: item.id)
        }
    }
    
    /// Removes the most recent navigation change in the root namespace.
    ///
    /// This is a convenience method that calls `removeLast(from: .root)`.
    /// If the root stack has items, this method removes the top item. If the
    /// stack is empty but a modal is showing, this method dismisses the modal.
    /// If both the stack and modal are empty, this method does nothing.
    public mutating func removeLast() {
        removeLast(from: .root)
    }
    
    /// Creates an empty presentation path.
    public init() {}
}

extension PresentationPath: CustomDebugStringConvertible {
    /// A textual snapshot of all namespaces, their navigation stacks, and
    /// currently presented items.
    public var debugDescription: String {
        stack
            .sorted { String(describing: $0.key) < String(describing: $1.key) }
            .map { namespace, container in
            let pathDescription = container.path.codable.debugDescription
            let itemDescription = container.item.map { "\($0.value)" } ?? "nil"
            return "Namespace: \(namespace), Path: [\(pathDescription)], Item: \(itemDescription)"
            }
            .joined(separator: "\n")
    }
}
