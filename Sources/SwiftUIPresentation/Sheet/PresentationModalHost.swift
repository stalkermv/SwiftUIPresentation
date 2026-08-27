import SwiftUI

struct PresentationSheetBuildersModifier: ViewModifier {
    @Environment(\.presentationStackNamespace) private var namespace
    @Binding var path: PresentationPath

    func body(content: Content) -> some View {
        content.backgroundPreferenceValue(PresentationDestinationSheetPreferenceKey.self) { value in
            PresentationModalDestinationHost(
                path: $path,
                namespace: namespace,
                value: value
            )
        }
    }
}

private struct PresentationModalDestinationHost: View {
    @Binding var path: PresentationPath
    let namespace: PresentationStackNamespace
    let value: PresentationDestinationSheetPreferenceKey.Value

    var body: some View {
        let root = value.builders(path.stack[namespace]?.item)

        if #available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, *) {
            PresentationAdaptiveDestinationHost(
                root: root,
                path: $path,
                namespace: namespace,
                value: value
            )
        } else {
            PresentationModalHostView(
                path: $path,
                namespace: namespace,
                value: value,
                style: .sheet
            )
        }
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, *)
private struct PresentationAdaptiveDestinationHost: View {
    let root: AnyView
    @Binding var path: PresentationPath
    let namespace: PresentationStackNamespace
    let value: PresentationDestinationSheetPreferenceKey.Value

    var body: some View {
        Group(subviews: root) { subviews in
            let style = subviews.first?.containerValues.swiftUIPresentationHost ?? .sheet
            PresentationModalHostView(
                path: $path,
                namespace: namespace,
                value: value,
                style: style
            )
        }
    }
}

private struct PresentationModalHostView: View {
    @Binding var path: PresentationPath
    let namespace: PresentationStackNamespace
    let value: PresentationDestinationSheetPreferenceKey.Value
    let style: PresentationHost

    private var effectiveStyle: PresentationHost {
        #if os(iOS)
        style
        #else
        style == .fullScreenCover ? .sheet : style
        #endif
    }

    var body: some View {
        #if os(iOS)
        Color.clear
            .fullScreenCover(isPresented: presentationBinding(for: .fullScreenCover)) {
                PresentationDestinationContent(path: $path, namespace: namespace, value: value)
            }
            .sheet(isPresented: presentationBinding(for: .sheet)) {
                PresentationDestinationContent(path: $path, namespace: namespace, value: value)
            }
            .popover(isPresented: presentationBinding(for: .popover)) {
                PresentationDestinationContent(path: $path, namespace: namespace, value: value)
            }
        #else
        Color.clear
            .sheet(isPresented: presentationBinding(for: .sheet)) {
                PresentationDestinationContent(path: $path, namespace: namespace, value: value)
            }
            .popover(isPresented: presentationBinding(for: .popover)) {
                PresentationDestinationContent(path: $path, namespace: namespace, value: value)
            }
        #endif
    }

    private func presentationBinding(for requestedStyle: PresentationHost) -> Binding<Bool> {
        Binding(
            get: { effectiveStyle == requestedStyle && path.stack[namespace]?.item != nil },
            set: { isPresented in
                guard !isPresented, effectiveStyle == requestedStyle else { return }
                var pathCopy = path
                pathCopy.clearPresentedItem(in: namespace)
                path = pathCopy
            }
        )
    }
}

private struct PresentationDestinationContent: View {
    @Binding var path: PresentationPath
    let namespace: PresentationStackNamespace
    let value: PresentationDestinationSheetPreferenceKey.Value

    var body: some View {
        if let item = path.stack[namespace]?.item {
            value.builders(item)
                .id(item.id)
        }
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, *)
extension ContainerValues {
    @Entry var swiftUIPresentationHost: PresentationHost = .sheet
}

extension View {
    /// Selects the modal host for a destination registered with
    /// ``presentationDestination(for:destination:)``.
    ///
    /// On iOS 18 and macOS 15 or later, the selected host is used directly. On
    /// older runtimes, destinations use a standard sheet host.
    public func presentationHost(_ host: PresentationHost) -> some View {
        modifier(PresentationHostModifier(host: host))
    }

    /// Applies SwiftUI's compact-size-class adaptation to a destination.
    ///
    /// Use ``presentationHost(_:)`` when selecting a sheet, popover, or
    /// full-screen-cover host. This compatibility method is kept for clients
    /// of the 1.0 API and forwards to SwiftUI's native compact adaptation.
    @available(*, deprecated, message: "Use presentationHost(_:) for modal host selection.")
    public func presentationAdaptation(
        _ adaptation: SwiftUI.PresentationAdaptation
    ) -> some View {
        modifier(PresentationCompactAdaptationModifier(adaptation: adaptation))
    }
}

private struct PresentationHostModifier: ViewModifier {
    let host: PresentationHost

    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, *) {
            content.containerValue(\.swiftUIPresentationHost, host)
        } else {
            content
        }
    }
}

private struct PresentationCompactAdaptationModifier: ViewModifier {
    let adaptation: SwiftUI.PresentationAdaptation

    func body(content: Content) -> some View {
        content.presentationCompactAdaptation(adaptation)
    }
}
