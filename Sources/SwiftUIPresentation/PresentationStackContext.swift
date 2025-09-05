//
//  PresentationStackContext.swift
//  SwiftUIPresentation
//
//  Created by Valeriy Malishevskyi on 05.09.2025.
//

import SwiftUI

extension EnvironmentValues {
    var presentationStackNamespace: PresentationStackNamespace {
        get { self[PresentationStackNamespaceKey.self] }
        set { self[PresentationStackNamespaceKey.self] = newValue }
    }
}

private struct PresentationStackNamespaceKey: EnvironmentKey {
    static let defaultValue: PresentationStackNamespace = .root
}
