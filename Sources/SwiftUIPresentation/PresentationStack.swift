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
    
//    @State private var adaptation: PresentationAdaptation = .automatic
    
    private var itemBinding: Binding<PresentationPath.PresentationItem?> {
        Binding(
            get: { path.stack[namespace]?.item },
            set: { path.stack[namespace]?.item = $0 }
        )
    }
    
    func body(content: Content) -> some View {
        content.backgroundPreferenceValue(PresentationDestinationSheetPreferenceKey.self) { value in
            
            let root = value.builders(path.stack[namespace]?.item?.value)
            if #available(iOS 18.0, *) {
                Group(subviews: root) { subviews in
                    let presentationAdaptation = subviews.first?.containerValues.presentationAdaptation
                    let adaptation = unsafeBitCast(presentationAdaptation, to: PresentationAdaptation.self)
                    
                    let fullScreenCoverBinding = Binding(
                        get: {
                            if adaptation.kind == .fullScreenCover {
                                return path.stack[namespace]?.item
                            } else {
                                return nil
                            }
                        },
                        set: { newValue in
                            if adaptation.kind == .fullScreenCover {
                                path.stack[namespace]?.item = newValue
                            }
                        }
                    )
                    
                    let sheetBinding = Binding(
                        get: {
                            if adaptation.kind == .sheet || adaptation.kind == .automatic {
                                return path.stack[namespace]?.item
                            } else {
                                return nil
                            }
                        },
                        set: { newValue in
                            if adaptation.kind == .sheet || adaptation.kind == .automatic {
                                path.stack[namespace]?.item = newValue
                            }
                        }
                    )
                    
                    let popoverBinding = Binding(
                        get: {
                            if adaptation.kind == .popover {
                                return path.stack[namespace]?.item
                            } else {
                                return nil
                            }
                        },
                        set: { newValue in
                            if adaptation.kind == .popover {
                                path.stack[namespace]?.item = newValue
                            }
                        }
                    )
                    
                    Color.clear
                        .fullScreenCover(item: fullScreenCoverBinding) { destination in
                            value.builders(destination.value)
                        }
                        .sheet(item: sheetBinding) { destination in
                            value.builders(destination.value)
                        }
                        .popover(item: popoverBinding) { destination in
                            value.builders(destination.value)
                        }
                }
            } else {
                // Fallback on earlier versions
            }
        }
    }
}

struct PresentationAdaptationExtractor<Content: View, Subview: View>: View {
    var root: Content
    @ViewBuilder var content: (SwiftUI.PresentationAdaptation) -> Subview
    
    var body: some View {
        if #available(iOS 18.0, *) {
            ForEach(subviews: root) { subview in
                let adaptation = subview.containerValues.presentationAdaptation
                let _ = print("Adaptation: \(adaptation)")
                content(adaptation)
            }
//            content(.automatic)
        } else {
            content(.automatic)
        }
    }
}
//
struct PresentationAdaptation: Equatable {
    
    enum Kind: String {
        case automatic
        case none
        case popover
        case sheet
        case fullScreenCover
    }
    
    var kind: Kind
}

@available(iOS 18.0, *)
extension ContainerValues {
    @Entry var presentationAdaptation: SwiftUI.PresentationAdaptation = .automatic
}

extension View {
    nonisolated public func presentationAdaptation(_ adaptation: SwiftUI.PresentationAdaptation) -> some View {
        modifier(PresentationAdaptationModifier(adaptation: adaptation))
    }
}

struct PresentationAdaptationModifier: ViewModifier {
    let adaptation: SwiftUI.PresentationAdaptation
    
    func body(content: Content) -> some View {
        if #available(iOS 18.0, *) {
            content
                .preference(key: PresentationAdaptationPreferenceKey.self, value: adaptation)
                .containerValue(\.presentationAdaptation, adaptation)
        } else {
            // Fallback on earlier versions
        }
    }
}

struct PresentationAdaptationPreferenceKey: PreferenceKey {
    static let defaultValue: SwiftUI.PresentationAdaptation = .automatic
    
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = nextValue()
    }
}

func printRecursively(_ any: Any, indent: String = "") {
    let mirror = Mirror(reflecting: any)
    print("\(indent)\(mirror.subjectType): \(any)")
    for child in mirror.children {
        if let value = child.value as? Any {
            printRecursively(value, indent: indent + "  ")
        }
    }
}
