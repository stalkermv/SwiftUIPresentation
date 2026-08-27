//
//  PresentationStack.swift
//  SwiftUIPresentation
//
//  Created by Valeriy Malishevskyi on 05.09.2025.
//

import SwiftUI
import SwiftUIHelpers

/// A view that enables navigation by both pushing and presenting modals.
///
/// Use a presentation stack to combine hierarchical navigation with contextual
/// modal presentation while keeping one ``PresentationPath`` as the source of
/// truth.
///
/// ### Register destinations
///
/// ```swift
/// PresentationStack {
///     List(items) { item in
///         PresentationLink(value: item, method: .stack) {
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
///
/// ```swift
/// @State private var path = PresentationPath()
///
/// PresentationStack(path: $path) {
///     Button("Go to Settings") {
///         path.present(SettingsRoute())
///     }
/// }
/// ```
public struct PresentationStack<Content: View>: View {
    private let content: Content
    private let namespace: PresentationStackNamespace
    @StateOrBinding private var presentationPath: PresentationPath

    internal init(
        namespace: PresentationStackNamespace = .root,
        path: StateOrBinding<PresentationPath>,
        @ViewBuilder content: () -> Content
    ) {
        self.namespace = namespace
        self._presentationPath = path
        self.content = content()
    }

    private var pathBinding: Binding<NavigationPath> {
        Binding(
            get: { presentationPath.stack[namespace, default: .init()].path },
            set: { presentationPath.setNavigationPath($0, in: namespace) }
        )
    }

    private var presentationRouter: PresentationRouter {
        PresentationRouter(
            namespace: namespace,
            presentationPath: $presentationPath
        )
    }

    public var body: some View {
        NavigationStack(path: pathBinding) {
            content
                .modifier(PresentationSheetBuildersModifier(path: $presentationPath))
        }
        .environment(\.presentationStackNamespace, namespace)
        .environment(\.presentation, presentationRouter)
    }
}

extension PresentationStack {
    /// Creates a presentation stack that manages its own navigation state.
    public init(@ViewBuilder content: () -> Content) {
        self.init(path: .init(PresentationPath()), content: content)
    }

    /// Creates a presentation stack that you control with an external path.
    public init(
        path: Binding<PresentationPath>,
        @ViewBuilder content: () -> Content
    ) {
        self.init(path: .binding(path), content: content)
    }
}
