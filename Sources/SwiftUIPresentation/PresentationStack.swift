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

    func body(content: Content) -> some View {
        content.backgroundPreferenceValue(PresentationDestinationSheetPreferenceKey.self) { value in
            let root = value.builders(path.stack[namespace]?.item?.value)

            if #available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, *) {
                adaptivePresentationHost(root: root, value: value)
            } else {
                presentationHost(value: value, style: .sheet)
            }
        }
    }

    @available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, *)
    @ViewBuilder
    private func adaptivePresentationHost(
        root: AnyView,
        value: PresentationDestinationSheetPreferenceKey.Value
    ) -> some View {
        Group(subviews: root) { subviews in
            let adaptation = subviews.first
                .map { DecodedPresentationAdaptation($0.containerValues.presentationAdaptation) }
                ?? .automatic

            presentationHost(value: value, style: PresentationModalStyle(adaptation: adaptation))
        }
    }

    @ViewBuilder
    private func presentationHost(
        value: PresentationDestinationSheetPreferenceKey.Value,
        style: PresentationModalStyle
    ) -> some View {
        #if os(iOS)
        Color.clear
            .fullScreenCover(isPresented: isPresentedBinding(for: .fullScreenCover, activeStyle: style)) {
                sheetContent(value: value)
            }
            .sheet(isPresented: isPresentedBinding(for: .sheet, activeStyle: style)) {
                sheetContent(value: value)
            }
            .popover(isPresented: isPresentedBinding(for: .popover, activeStyle: style)) {
                sheetContent(value: value)
            }
        #else
        Color.clear
            .sheet(isPresented: isPresentedBinding(for: .sheet, activeStyle: style)) {
                sheetContent(value: value)
            }
            .popover(isPresented: isPresentedBinding(for: .popover, activeStyle: style)) {
                sheetContent(value: value)
            }
        #endif
    }

    private func isPresentedBinding(
        for style: PresentationModalStyle,
        activeStyle: PresentationModalStyle
    ) -> Binding<Bool> {
        Binding(
            get: { activeStyle == style && path.stack[namespace]?.item != nil },
            set: { newValue in
                guard !newValue else { return }
                var pathCopy = path
                pathCopy.clearPresentedItem(in: namespace)
                path = pathCopy
            }
        )
    }

    @ViewBuilder
    private func sheetContent(value: PresentationDestinationSheetPreferenceKey.Value) -> some View {
        if let item = path.stack[namespace]?.item {
            value.builders(item.value)
        }
    }
}

private enum PresentationModalStyle: Equatable {
    case sheet
    case popover
    case fullScreenCover

    @available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, *)
    init(adaptation: DecodedPresentationAdaptation) {
        switch adaptation.kind {
        case .popover:
            self = .popover
        case .fullScreenCover:
            #if os(iOS)
            self = .fullScreenCover
            #else
            self = .sheet
            #endif
        case .automatic, .none, .sheet:
            self = .sheet
        }
    }
}

private struct DecodedPresentationAdaptation: Equatable {
    enum Kind: String {
        case automatic
        case none
        case popover
        case sheet
        case fullScreenCover
    }

    let kind: Kind

    static let automatic = DecodedPresentationAdaptation(kind: .automatic)

    init(kind: Kind) {
        self.kind = kind
    }

    @available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, *)
    init(_ adaptation: SwiftUI.PresentationAdaptation) {
        self = unsafeBitCast(adaptation, to: DecodedPresentationAdaptation.self)
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, *)
extension ContainerValues {
    @Entry var presentationAdaptation: SwiftUI.PresentationAdaptation = .automatic
}

extension View {
    /// Sets the preferred modal presentation host for destinations shown by
    /// ``PresentationLink`` or ``PresentationRouter/present(value:)``.
    ///
    /// Use this modifier inside a destination registered with
    /// `presentationDestination(for:destination:)` when one destination
    /// type should stay the same but the host should switch between standard
    /// sheets, popovers, or a full-screen cover.
    ///
    /// On runtimes earlier than iOS 18, SwiftUIPresentation falls back to a
    /// standard sheet.
    public func presentationAdaptation(_ adaptation: SwiftUI.PresentationAdaptation) -> some View {
        modifier(PresentationAdaptationModifier(adaptation: adaptation))
    }
}

private struct PresentationAdaptationModifier: ViewModifier {
    let adaptation: SwiftUI.PresentationAdaptation

    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, *) {
            content.containerValue(\.presentationAdaptation, adaptation)
        } else {
            content
        }
    }
}
