//
//  PresentationSheetViewModifier.swift
//  SwiftUIPresentation
//
//  Created by Valeriy Malishevskyi on 05.09.2025.
//

import SwiftUI

struct PresentationDestinationSheetModifier<D, C>: ViewModifier
where D: Hashable, C: View {
    
    let data: D.Type
    let destination: (D) -> C
    
    func body(content: Content) -> some View {
        content.transformPreference(PresentationDestinationSheetPreferenceKey.self) { value in
            let builders = value.builders
            value.builders = { item in
                if let item, let data = item.value as? D {
                    return AnyView(
                        destination(data)
                            .environment(\.presentationStackNamespace, .child(item.id))
                    )
                } else {
                    return builders(item)
                }
            }
        }
    }
}

extension View {
    /// Embeds the current destination in a nested ``PresentationStack`` when it
    /// appears inside a presented sheet.
    ///
    /// Use this modifier on a destination view when that sheet should support
    /// its own stack navigation without leaking state into the parent stack.
    public func embedInPresentation() -> some View {
        self.modifier(PresentationContainerViewModifier())
    }
}

struct PresentationContainerViewModifier : ViewModifier {
    @Environment(\.presentationStackNamespace) private var namespace
    @Environment(\.presentation) private var presentation
        
    func body(content: Content) -> some View {
        if let presentation, namespace != .root {
            PresentationStack(
                namespace: namespace,
                path: .binding(presentation.$presentationPath),
                content: { content }
            )
        } else {
            content
        }
    }
}
