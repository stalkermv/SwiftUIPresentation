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
public struct PresentationPath: Equatable, Sendable {

    // MARK: - Internal Types

    internal struct PresentationItem: Identifiable, Hashable, @unchecked Sendable {
        let value: AnyHashable
        var id: AnyHashable { value }

        init<T: Hashable>(_ value: T) {
            self.value = AnyHashable(value)
        }
    }

    internal struct PresentationContainer: Equatable, @unchecked Sendable {
        var path: NavigationPath
        var item: PresentationItem?

        init(_ path: NavigationPath = NavigationPath(), item: PresentationItem? = nil) {
            self.path = path
            self.item = item
        }
    }

    // MARK: - Storage

    var stack: [PresentationStackNamespace: PresentationContainer] = [:]
    
    /// Adds a value to the navigation stack for the specified namespace.
    ///
    /// The new value becomes the top item on the stack. If no stack exists
    /// for this namespace, this method creates one.
    public mutating func append<T: Hashable>(_ element: T, namespace: PresentationStackNamespace = .root) {
        var container = stack[namespace, default: PresentationContainer()]
        container.path.append(element)
        stack[namespace] = container
    }
    
    /// Shows a value in a sheet for the specified namespace.
    ///
    /// If a sheet is already showing for this namespace, this method replaces it
    /// with the new value.
    public mutating func present<T: Hashable>(_ element: T, over namespace: PresentationStackNamespace) {
        var container = stack[namespace, default: PresentationContainer()]
        container.item = PresentationItem(element)
        stack[namespace] = container
    }
    
    /// Clears the presented item in the given namespace (used when sheet is dismissed via UI).
    /// Also removes the child namespace for that item's value so the next presentation
    /// starts with a fresh navigation stack inside the sheet (avoids stale state).
    internal mutating func clearPresentedItem(in namespace: PresentationStackNamespace) {
        var container = stack[namespace, default: PresentationContainer()]
        let presentedValue = container.item?.value
        container.item = nil
        stack[namespace] = container
        if let value = presentedValue {
            removeChildNamespace(forPresentedValue: value)
        }
    }

    /// Dismisses the sheet that is currently presenting the given value.
    ///
    /// Finds the namespace whose container has `item?.value == value`, clears that
    /// container's item, and removes the child namespace so the next presentation
    /// starts with a fresh stack inside the sheet.
    public mutating func dismiss(presenting value: AnyHashable) {
        for (ns, container) in stack where container.item?.value == value {
            var updated = container
            updated.item = nil
            stack[ns] = updated
            removeChildNamespace(forPresentedValue: value)
            return
        }
    }
    
    /// Returns whether the namespace currently presents a modal item.
    public func isPresented(in namespace: PresentationStackNamespace) -> Bool {
        if let container = stack[namespace] {
            return container.item != nil
        }
        return false
    }

    /// Removes the most recent navigation change in the specified namespace.
    ///
    /// If the namespace stack has items, this method removes the top item. If the
    /// stack is empty but a sheet is showing, this method dismisses the sheet.
    /// If both the stack and sheet are empty, this method does nothing.
    public mutating func removeLast(from namespace: PresentationStackNamespace = .root) {
        var container = stack[namespace, default: PresentationContainer()]
        if !container.path.isEmpty {
            container.path.removeLast()
        } else if container.item != nil {
            let presentedValue = container.item?.value
            container.item = nil
            if let value = presentedValue {
                removeChildNamespace(forPresentedValue: value)
            }
        } else if case .child(let key) = namespace {
            dismiss(presenting: key.key)
            return
        } else {
            return
        }
        stack[namespace] = container
    }

    // MARK: - Private Helpers

    private mutating func removeChildNamespace(forPresentedValue value: AnyHashable) {
        stack.removeValue(forKey: .child(PresentationStackKey(key: value)))
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
        var descriptions: [String] = []
        for (namespace, container) in stack {
            let pathDescription = container.path.codable.debugDescription
            let itemDescription = container.item.map { "\($0.value)" } ?? "nil"
            descriptions.append("Namespace: \(namespace), Path: [\(pathDescription)], Item: \(itemDescription)")
        }
        return descriptions.joined(separator: "\n")
    }
}
