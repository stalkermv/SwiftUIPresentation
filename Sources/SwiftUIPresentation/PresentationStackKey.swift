//
//  PresentationStackKey.swift
//  SwiftUIPresentation
//
//  Created by Valeriy Malishevskyi on 09.09.2025.
//

/// An identifier that represents a nested presentation context.
public struct PresentationStackKey: Hashable, @unchecked Sendable {
    let key: AnyHashable
}
