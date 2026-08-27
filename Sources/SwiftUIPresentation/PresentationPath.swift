//
//  PresentationPath.swift
//  SwiftUIPresentation
//
//  Created by Valeriy Malishevskyi on 05.09.2025.
//

import Foundation
import SwiftUI

/// A value that tracks navigation stacks and optional sheet items across
/// presentation namespaces.
///
/// A presentation path drives both hierarchical (push) and contextual (sheet)
/// presentation. Each namespace maintains its own ordered stack plus at most
/// one presented item. Mutating methods provide clear, testable semantics.
///
/// ### Programmatic control
/// Update the path directly or through a ``PresentationRouter``:
/// ```swift
/// path.append(user)
/// path.present(settings, over: .root)
/// path.removeLast() // Pops last element or dismisses sheet if stack empty.
/// ```
///
/// ### Namespaces
/// Sheets create child namespaces so navigation inside a modal doesn’t leak
/// into the root stack.
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
        stack[namespace] = container
    }
    
    /// Shows a value in a sheet for the specified namespace.
    ///
    /// If a sheet is already showing for this namespace, this method replaces it
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
        stack[namespace] = container
    }
    
    /// Clears the presented item in the given namespace (used when sheet is dismissed via UI).
    /// Also removes the child namespace for that item's value so the next presentation
    /// starts with a fresh navigation stack inside the sheet (avoids stale state).
    internal mutating func clearPresentedItem(in namespace: PresentationStackNamespace) {
        guard var container = stack[namespace], let item = container.item else { return }
        container.item = nil
        stack[namespace] = container
        removeNamespaceTree(for: item.id)
    }

    /// Dismisses the presented item in a namespace.
    ///
    /// For a child namespace, this dismisses the sheet that owns that child
    /// namespace. Dismissing also removes all nested presentation state below
    /// the dismissed item.
    public mutating func dismiss(in namespace: PresentationStackNamespace = .root) {
        switch namespace {
        case .root:
            clearPresentedItem(in: .root)
        case .child(let key):
            dismiss(presenting: key)
        }
    }

    /// Dismisses the sheet that is currently presenting the given value.
    ///
    /// Finds the namespace whose container has `item?.value == value`, clears that
    /// container's item, and removes the child namespace so the next presentation
    /// starts with a fresh stack inside the sheet.
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
    /// stack is empty but a sheet is showing, this method dismisses the sheet.
    /// If both the stack and sheet are empty, this method does nothing.
    public mutating func removeLast(from namespace: PresentationStackNamespace = .root) {
        guard var container = stack[namespace] else {
            if case .child(let key) = namespace {
                dismiss(presenting: key)
            }
            return
        }

        if !container.path.isEmpty {
            container.path.removeLast()
            stack[namespace] = container
        } else if container.item != nil {
            clearPresentedItem(in: namespace)
        } else if case .child(let key) = namespace {
            dismiss(presenting: key)
        }
    }

    // MARK: - Private Helpers

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
    /// stack is empty but a sheet is showing, this method dismisses the sheet.
    /// If both the stack and sheet are empty, this method does nothing.
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
