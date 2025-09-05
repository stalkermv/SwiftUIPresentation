import Testing
@testable import SwiftUIPresentation

struct PresentationPathContractTests {
    @Test("Append adds element to root namespace path")
    func testAppendAddsElementToNamespaceRoot() {
        var path = PresentationPath()
        path.append("A")
        // Currently internal structure: stack[.root]?.path should contain one element
        let container = path.stack[.root]
        #expect(container != nil, "Container for .root namespace should exist after append")
        #expect(container?.path.count == 1, "Path should contain exactly one element after append")
    }
    
    @Test("Present sets item for root namespace")
    func testPresentSetsItemForNamespace() {
        var path = PresentationPath()
        path.present("Sheet", over: .root)
        let container = path.stack[.root]
        
        #expect(container != nil, "Container for .root namespace should exist after present")
        #expect(container?.item != nil, "Item must be set after present call")
    }
    
    @Test("Present overrides existing item in root namespace")
    func testAppendDoesNotAccidentallyClearPresentedItem() {
        var path = PresentationPath()
        path.present("Modal", over: .root)
        path.append("A")
        
        #expect(path.stack[.root]?.item != nil, "Presented item should persist after stack append")
    }

    @Test("Second present replaces previous item in same namespace")
    func testPresentReplacesPreviousItem() {
        var path = PresentationPath()
        path.present("First", over: .root)
        path.present("Second", over: .root)
        let item = path.stack[.root]?.item?.value as? String
        #expect(item == "Second", "Second present should replace the first item")
    }

    @Test("Multiple appends accumulate in order")
    func testMultipleAppendsAccumulate() {
        var path = PresentationPath()
        path.append("A")
        path.append("B")
        path.append("C")
        let container = path.stack[.root]
        #expect(container?.path.count == 3, "Path should contain three elements after three appends")
    }

    @Test("Debug description contains namespace and elements")
    func testDebugDescriptionContainsInfo() {
        var path = PresentationPath()
        path.append("A")
        path.present("Sheet", over: .root)
        
        #expect(path.stack[.root]?.item != nil, "Debug description should include item info")
        #expect(path.stack[.root]?.path.count == 1, "Debug description should include path info")
        #expect(path.stack.keys.contains(.root), "Debug description should include namespace info")
    }
    
    @Test("Multiple namespaces are isolated")
    func testMultipleNamespacesAreIsolated() {
        var path = PresentationPath()
        let key1 = PresentationStackKey(key: "K1")
        let key2 = PresentationStackKey(key: "K2")
        path.append("A", namespace: .child(key1))
        path.append("B", namespace: .child(key2))
        
        #expect(path.stack.count == 2, "There should be two separate namespaces in the stack")
        #expect(path.stack[.child(key1)]?.path.count == 1, "Namespace K1 should have one element")
        #expect(path.stack[.child(key2)]?.path.count == 1, "Namespace K2 should have one element")
    }
    
    @Test("RemoveLast removes last element from root namespace")
    func testRemoveLastCurrentImplementationDoesNothing() {
        var path = PresentationPath()
        path.append("A")
        #expect(path.stack[.root]?.path.count == 1, "Path should contain one element before removeLast")
        path.removeLast()
        #expect(path.stack[.root]?.path.count == 0, "removeLast should remove last element when path not empty")
    }
    
    @Test("RemoveLast backwards compatibility - defaults to root namespace")
    func testRemoveLastBackwardsCompatibility() {
        var path = PresentationPath()
        let childKey = PresentationStackKey(key: "child")
        let childNamespace = PresentationStackNamespace.child(childKey)
        
        // Add elements to both namespaces
        path.append("RootA", namespace: .root)
        path.append("ChildA", namespace: childNamespace)
        
        // removeLast() without parameters should only affect root
        path.removeLast()
        
        #expect(path.stack[.root]?.path.count == 0, "Root namespace should be affected by removeLast()")
        #expect(path.stack[childNamespace]?.path.count == 1, "Child namespace should be unaffected by removeLast()")
    }

    @Test("RemoveLast removes presented item when path empty")
    func testRemoveLastRemovesPresentedItemWhenPathEmpty() {
        var path = PresentationPath()
        path.present("Modal", over: .root)
        #expect(path.stack[.root]?.item != nil, "Item should be set before removeLast")
        path.removeLast()
        #expect(path.stack[.root]?.item == nil, "removeLast should clear presented item when path is empty")
    }
    
    @Test("RemoveLast with namespace parameter removes element from specific namespace")
    func testRemoveLastWithNamespaceParameter() {
        var path = PresentationPath()
        let childKey = PresentationStackKey(key: "test-child")
        let childNamespace = PresentationStackNamespace.child(childKey)
        
        path.append("A", namespace: childNamespace)
        path.append("B", namespace: childNamespace)
        #expect(path.stack[childNamespace]?.path.count == 2, "Child namespace should have 2 elements")
        
        path.removeLast(from: childNamespace)
        #expect(path.stack[childNamespace]?.path.count == 1, "removeLast should remove last element from child namespace")
    }
    
    @Test("RemoveLast with namespace parameter dismisses sheet when stack empty")
    func testRemoveLastWithNamespaceDismissesSheet() {
        var path = PresentationPath()
        let childKey = PresentationStackKey(key: "test-modal")
        let childNamespace = PresentationStackNamespace.child(childKey)
        
        path.present("Modal", over: childNamespace)
        #expect(path.stack[childNamespace]?.item != nil, "Item should be set in child namespace")
        
        path.removeLast(from: childNamespace)
        #expect(path.stack[childNamespace]?.item == nil, "removeLast should dismiss sheet in child namespace")
    }
    
    @Test("RemoveLast with namespace does not affect other namespaces")
    func testRemoveLastWithNamespaceIsolation() {
        var path = PresentationPath()
        let childKey = PresentationStackKey(key: "test-isolation")
        let childNamespace = PresentationStackNamespace.child(childKey)
        
        path.append("Root1", namespace: .root)
        path.append("Child1", namespace: childNamespace)
        
        path.removeLast(from: childNamespace)
        
        #expect(path.stack[.root]?.path.count == 1, "Root namespace should be unaffected")
        #expect(path.stack[childNamespace]?.path.count == 0, "Child namespace should be empty")
    }
}
