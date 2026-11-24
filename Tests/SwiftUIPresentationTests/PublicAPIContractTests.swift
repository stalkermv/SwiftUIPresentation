import SwiftUI
import Testing
import SwiftUIPresentation

struct PublicAPIContractTests {
    @Test("Value and host APIs compose in SwiftUI")
    @MainActor
    func valueAndHostAPIsCompose() {
        struct Route: Hashable {
            let id: Int
        }

        let route = Route(id: 1)
        let link = PresentationLink(value: route, method: .stack) {
            Text("Open")
        }
        let hostConfiguredView = Text("Destination")
            .presentationHost(.popover)
        let stack = PresentationStack {
            Text("Root")
        }

        _ = link.body
        _ = hostConfiguredView
        _ = stack
    }

    @Test("Presentation method and host remain value types")
    func presentationModesHaveStableValueSemantics() {
        let methods: Set<PresentationMethod> = [.sheet, .stack]
        let hosts: Set<PresentationHost> = [.sheet, .popover, .fullScreenCover]

        #expect(methods.count == 2)
        #expect(hosts.count == 3)
    }
}
