//
//  PresentationStackNamespace.swift
//  SwiftUIPresentation
//
//  Created by Valeriy Malishevskyi on 09.09.2025.
//

/// A context that isolates navigation state from other contexts.
///
/// Each namespace maintains its own navigation stack and optional sheet item.
/// When you show a sheet, it automatically gets its own child namespace so
/// navigation inside the sheet doesn't interfere with navigation outside it.
public enum PresentationStackNamespace: Hashable, Sendable, CustomStringConvertible {
    /// Primary/root namespace.
    case root
    /// Child namespace (created when a sheet hosts an embedded stack).
    case child(PresentationStackKey)

    public var description: String {
        switch self {
        case .root:
            "root"
        case .child(let key):
            "child(\(key))"
        }
    }
}
