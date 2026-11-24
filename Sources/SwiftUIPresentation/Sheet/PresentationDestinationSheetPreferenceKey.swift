//
//  PresentationDestinationSheetPreferenceKey.swift
//  SwiftUIPresentation
//
//  Created by Valeriy Malishevskyi on 05.09.2025.
//

import SwiftUI

struct PresentationDestinationSheetPreferenceKey: PreferenceKey {
    
    struct Value {
        var builders: (PresentationPath.PresentationItem?) -> AnyView
        
        init(_ builders: @escaping (PresentationPath.PresentationItem?) -> AnyView) {
            self.builders = builders
        }
    }
    
    // SwiftUI's PreferenceKey requirement is nonisolated, while this value
    // carries a view-building closure that is intentionally evaluated by the
    // view system. Keep the immutable default explicit rather than claiming
    // that the closure itself is Sendable.
    nonisolated(unsafe) static let defaultValue: Value = .init { _ in AnyView(EmptyView()) }
    
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = nextValue()
    }
}
