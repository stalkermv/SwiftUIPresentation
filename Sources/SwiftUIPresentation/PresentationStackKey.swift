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
/// presentation instances. The key is opaque; instances are created by the
/// presentation system rather than by app code.
public struct PresentationStackKey: Hashable, Sendable, CustomStringConvertible {
    private let rawValue: UUID

    init() {
        rawValue = UUID()
    }

    public var description: String {
        rawValue.uuidString
    }
}
