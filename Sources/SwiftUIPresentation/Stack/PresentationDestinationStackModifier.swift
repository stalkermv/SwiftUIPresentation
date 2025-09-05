//
//  PresentationDestinationStackModifier.swift
//  SwiftUIPresentation
//
//  Created by Valeriy Malishevskyi on 05.09.2025.
//

import SwiftUI

struct PresentationDestinationStackModifier<D, C>: ViewModifier where D : Hashable, C : View {
    let data: D.Type
    let destination: (D) -> C

    func body(content: Content) -> some View {
        content
            .navigationDestination(for: data, destination: destination)
    }
}
