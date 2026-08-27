import SwiftUI
import Testing
import ViewInspector
@testable import SwiftUIPresentation

@MainActor
struct PresentationLinkTests {
    @Test("PresentationLink is disabled without a presentation stack")
    func disablesWithoutRouter() throws {
        let link = PresentationLink(value: "Settings") {
            Text("Settings")
        }

        #expect(try link.inspect().button().isDisabled())
    }
}
