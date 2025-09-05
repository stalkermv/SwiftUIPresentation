//
//  PresentationStack.swift
//  SwiftUIPresentation
//
//  Created by Valeriy Malishevskyi on 05.09.2025.
//

import SwiftUI
import SwiftUIHelpers





/// A view that enables navigation by both pushing and presenting sheets.
///
/// Use a presentation stack to create navigation experiences that seamlessly
/// combine hierarchical navigation (like drill-down lists) with contextual
/// sheets (like quick edits or settings). The stack coordinates a unified
/// ``PresentationPath`` that tracks both kinds of navigation.
///
/// ### Register destinations
/// Tell the stack what view to show for each data type:
/// ```swift
/// PresentationStack {
///     List(items) { item in
///         PresentationLink(value: item, presentationType: .stack) {
///             Text(item.title)
///         }
///     }
///     .presentationDestination(for: Item.self) { item in
///         ItemDetail(item: item)
///     }
/// }
/// ```
///
/// ### Control navigation programmatically
/// Bind to a path to trigger navigation from your code:
/// ```swift
/// @State private var path = PresentationPath()
///
/// PresentationStack(path: $path) {
///     Button("Go to Settings") {
///         path.present(SettingsView(), over: .root)
///     }
/// }
/// ```
public struct PresentationStack<Content: View>: View {
    
    private let content: () -> Content
    private let namespace: PresentationStackNamespace
    @StateOrBinding private var presentationPath: PresentationPath
    @State private var presentationRouter: PresentationRouter
    
    internal init(
        namespace: PresentationStackNamespace = .root,
        path: StateOrBinding<PresentationPath>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.namespace = namespace
        self._presentationPath = path
        self.content = content
        
        self._presentationRouter = State(
            wrappedValue: PresentationRouter(
                namespace: namespace,
                presentationPath: path.projectedValue
            )
        )
    }
    
    private var pathBinding: Binding<NavigationPath> {
        Binding(
            get: { presentationPath.stack[namespace, default: .init()].path },
            set: { presentationPath.stack[namespace, default: .init()].path = $0 }
        )
    }
    
    public var body: some View {
        NavigationStack(path: pathBinding) {
            content()
                .modifier(PresentationSheetBuildersModifier(path: $presentationPath))
        }
        .environment(\.presentationStackNamespace, namespace)
        .environment(\.presentation, presentationRouter)
    }
}

extension PresentationStack {
    /// Creates a presentation stack that manages its own navigation state.
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.init(path: .init(PresentationPath()), content: content)
    }
    
    /// Creates a presentation stack that you control with an external path.
    public init(path: Binding<PresentationPath>, @ViewBuilder content: @escaping () -> Content) {
        self.init(path: .binding(path), content: content)
    }
}

struct PresentationSheetBuildersModifier: ViewModifier {
    @Environment(\.presentationStackNamespace) private var namespace
    @Binding var path: PresentationPath
    
    private var itemBinding: Binding<PresentationPath.PresentationItem?> {
        Binding(
            get: { path.stack[namespace]?.item },
            set: { path.stack[namespace]?.item = $0 }
        )
    }
    
    func body(content: Content) -> some View {
        content.backgroundPreferenceValue(PresentationDestinationSheetPreferenceKey.self) { builders in
            Color.clear.sheet(item: itemBinding) { destination in
                builders.builders(destination.value)
            }
        }
    }
}
