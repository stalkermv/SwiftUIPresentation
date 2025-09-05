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
            value.builders = { data in
                if let data = data as? D {
                    return AnyView(destination(data).embedInPresentation(data))
                } else {
                    return builders(data)
                }
            }
        }
    }
}

private extension View {
    func embedInPresentation<K: Hashable>(_ key: K) -> some View {
        self.modifier(PresentationContainerViewModifier(key: key))
    }
}

struct PresentationContainerViewModifier<Key: Hashable> : ViewModifier {
    @Environment(\.presentation) private var presentation
    
    let key: Key
    
    func body(content: Content) -> some View {
        if let presentation {
            PresentationStack(
                namespace: .child(PresentationStackKey(key: key)),
                path: .binding(presentation.$presentationPath),
                content: { content }
            )
        } else {
            content
        }
    }
}
