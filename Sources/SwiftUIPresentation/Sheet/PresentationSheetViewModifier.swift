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
                    return AnyView(
                        destination(data)
                            .environment(\.presentationStackNamespace, .child(PresentationStackKey(key: data)))
                    )
                } else {
                    return builders(data)
                }
            }
        }
    }
}

extension View {
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
