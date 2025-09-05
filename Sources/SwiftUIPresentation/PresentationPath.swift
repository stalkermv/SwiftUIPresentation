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
    
    struct PresentationItem: Identifiable, Hashable, @unchecked Sendable {
        let value: AnyHashable
        var id: AnyHashable { value }
        
        init<T: Hashable>(_ value: T) {
            self.value = AnyHashable(value)
        }
    }
    
    struct PresentationContainer: Equatable, @unchecked Sendable {
        var path: NavigationPath
        var item: PresentationItem?

        init(_ path: NavigationPath = NavigationPath(), item: PresentationItem? = nil) {
            self.path = path
            self.item = item
        }
    }
    
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
            container.item = nil
        } else {
            return
        }
        stack[namespace] = container
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
}

extension PresentationPath: CustomDebugStringConvertible {
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
