//
//  EnvironmentValues+Presentation.swift
//  SwiftUIPresentation
//
//  Created by Valeriy Malishevskyi on 05.09.2025.
//

import SwiftUI

extension EnvironmentValues {
    @MainActor public var presentation: PresentationRouter? {
        get { self[PresentationEnvironmentKey.self] }
        set { self[PresentationEnvironmentKey.self] = newValue }
    }
}

private struct PresentationEnvironmentKey: EnvironmentKey {
    static let defaultValue: PresentationRouter? = nil
}

