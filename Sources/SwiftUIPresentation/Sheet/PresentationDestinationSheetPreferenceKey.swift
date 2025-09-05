//
//  PresentationDestinationSheetPreferenceKey.swift
//  SwiftUIPresentation
//
//  Created by Valeriy Malishevskyi on 05.09.2025.
//

import SwiftUI

struct PresentationDestinationSheetPreferenceKey: PreferenceKey {
    
    struct Value {
        var builders: (AnyHashable) -> AnyView
        
        init(_ builders: @escaping (AnyHashable) -> AnyView) {
            self.builders = builders
        }
    }
    
    nonisolated(unsafe) static var defaultValue: Value = .init({ _ in AnyView(EmptyView()) })
    
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = nextValue()
    }
}
