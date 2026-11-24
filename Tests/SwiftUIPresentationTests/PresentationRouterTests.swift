import Testing
import SwiftUI
@testable import SwiftUIPresentation

@MainActor
struct PresentationRouterTests {
    @Test("Router push delegates to path append")
    func testPushDelegates() {
        final class Box { var value: PresentationPath; init(_ v: PresentationPath) { value = v } }
        let box = Box(PresentationPath())
        let binding = Binding(get: { box.value }, set: { box.value = $0 })
        let router = PresentationRouter(namespace: .root, presentationPath: binding)
        router.push("A")
        #expect(box.value.stack[.root]?.path.count == 1, "Push should append an element to root path")
    }
    
    @Test("Present adds item to specified namespace")
    func testPresentAddsItemToSpecifiedNamespace() {
        final class Box { var value: PresentationPath; init(_ v: PresentationPath) { value = v } }
        let box = Box(PresentationPath())
        let binding = Binding(get: { box.value }, set: { box.value = $0 })
        let router = PresentationRouter(namespace: .root, presentationPath: binding)
        router.present("Modal")
        #expect(box.value.stack[.root]?.item != nil, "Present should set item in root namespace")
    }
    
    @Test("Pop removes last element from router's namespace")
    func testPopRemovesLastElement() {
        final class Box { var value: PresentationPath; init(_ v: PresentationPath) { value = v } }
        let box = Box(PresentationPath())
        let binding = Binding(get: { box.value }, set: { box.value = $0 })
        let router = PresentationRouter(namespace: .root, presentationPath: binding)
        
        router.push("A")
        router.push("B")
        #expect(box.value.stack[.root]?.path.count == 2, "Router should push two elements")
        
        router.pop()
        #expect(box.value.stack[.root]?.path.count == 1, "Pop should remove last element")
    }
    
    @Test("Pop dismisses sheet when stack empty")
    func testPopDismissesSheetWhenStackEmpty() {
        final class Box { var value: PresentationPath; init(_ v: PresentationPath) { value = v } }
        let box = Box(PresentationPath())
        let binding = Binding(get: { box.value }, set: { box.value = $0 })
        let router = PresentationRouter(namespace: .root, presentationPath: binding)
        
        router.present("Modal")
        #expect(box.value.stack[.root]?.item != nil, "Modal should be presented")
        
        router.pop()
        #expect(box.value.stack[.root]?.item == nil, "Pop should dismiss sheet when stack empty")
    }
    
    @Test("Dismiss removes presented sheet")
    func testDismissRemovesPresentedSheet() {
        final class Box { var value: PresentationPath; init(_ v: PresentationPath) { value = v } }
        let box = Box(PresentationPath())
        let binding = Binding(get: { box.value }, set: { box.value = $0 })
        let router = PresentationRouter(namespace: .root, presentationPath: binding)
        
        router.present("Modal")
        #expect(box.value.stack[.root]?.item != nil, "Modal should be presented")
        
        router.dismiss()
        #expect(box.value.stack[.root]?.item == nil, "Dismiss should remove presented sheet")
    }
    
    @Test("Dismiss does not affect navigation stack")
    func testDismissDoesNotAffectStack() {
        final class Box { var value: PresentationPath; init(_ v: PresentationPath) { value = v } }
        let box = Box(PresentationPath())
        let binding = Binding(get: { box.value }, set: { box.value = $0 })
        let router = PresentationRouter(namespace: .root, presentationPath: binding)
        
        router.push("A")
        router.present("Modal")
        #expect(box.value.stack[.root]?.path.count == 1, "Stack should have one element")
        #expect(box.value.stack[.root]?.item != nil, "Modal should be presented")
        
        router.dismiss()
        #expect(box.value.stack[.root]?.path.count == 1, "Stack should remain unchanged")
        #expect(box.value.stack[.root]?.item == nil, "Modal should be dismissed")
    }

    @Test("Dismiss from child namespace closes sheet hosted by root")
    func testDismissFromChildNamespaceClosesSheet() throws {
        final class Box { var value: PresentationPath; init(_ v: PresentationPath) { value = v } }
        let box = Box(PresentationPath())
        box.value.present("Sheet", over: .root)
        #expect(box.value.stack[.root]?.item != nil, "Root should have presented sheet")

        let binding = Binding(get: { box.value }, set: { box.value = $0 })
        let childKey = try #require(box.value.stack[.root]?.item?.id)
        let router = PresentationRouter(namespace: .child(childKey), presentationPath: binding)
        router.dismiss()

        #expect(box.value.stack[.root]?.item == nil, "Dismiss from inside sheet should clear root item")
    }
}

@MainActor
struct PresentationRouterModalStateTests {
    private final class Box {
        var value: PresentationPath
        init(_ value: PresentationPath) { self.value = value }
    }

    @Test("isPresentingModal is true only while the namespace presents something")
    func presentingModal() {
        let box = Box(PresentationPath())
        let binding = Binding(get: { box.value }, set: { box.value = $0 })
        let router = PresentationRouter(namespace: .root, presentationPath: binding)

        #expect(router.isPresentingModal == false)
        router.present("Modal")
        #expect(router.isPresentingModal)
        router.dismiss()
        #expect(router.isPresentingModal == false)
    }

    @Test("isInModal is false for the root stack and true for a sheet's stack")
    func inModal() throws {
        let box = Box(PresentationPath())
        box.value.present("Sheet", over: .root)
        let binding = Binding(get: { box.value }, set: { box.value = $0 })
        let childKey = try #require(box.value.stack[.root]?.item?.id)

        #expect(PresentationRouter(namespace: .root, presentationPath: binding).isInModal == false)
        #expect(PresentationRouter(namespace: .child(childKey), presentationPath: binding).isInModal)
    }

    @available(*, deprecated)
    @Test("The deprecated isPresented still means isPresentingModal")
    func deprecatedAlias() {
        let box = Box(PresentationPath())
        let binding = Binding(get: { box.value }, set: { box.value = $0 })
        let router = PresentationRouter(namespace: .root, presentationPath: binding)

        router.present("Modal")
        #expect(router.isPresented == router.isPresentingModal)
    }
}
