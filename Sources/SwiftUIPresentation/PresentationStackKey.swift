//
//  PresentationStackKey.swift
//  SwiftUIPresentation
//
//  Created by Valeriy Malishevskyi on 09.09.2025.
//

import Foundation

/// A stable identity for one presented destination and its nested navigation.
///
/// The identity is intentionally independent from the destination value. Two
/// presentations may contain equal values while still representing different
/// presentation instances.
@frozen
public struct PresentationStackKey: Hashable, Sendable, CustomStringConvertible {
    /// The underlying identity value.
    public let rawValue: UUID

    /// Creates a new presentation identity.
    public init() {
        rawValue = UUID()
    }

    internal init(rawValue: UUID) {
        self.rawValue = rawValue
    }

    public var description: String {
        rawValue.uuidString
    }
}
