# Programmatic Navigation

Drive presentation state from code instead of only from links.

## Use the environment router

``PresentationRouter`` is available through the environment inside a
``PresentationStack``:

```swift
struct UserProfile: View {
    @Environment(\.presentation) private var presentation

    var body: some View {
        VStack {
            Button("Show settings") {
                presentation?.present(SettingsRoute())
            }

            Button("Push details") {
                presentation?.push(RelatedUserRoute())
            }

            Button("Go back") {
                presentation?.pop()
            }
        }
    }
}
```

Use ``PresentationRouter/isPresented`` when UI needs to react to whether the
current namespace already hosts a modal destination.

## Mutate the path directly

``PresentationPath`` gives you value-based control that is easy to test:

```swift
var path = PresentationPath()

path.append(UserRoute(id: userID))
path.present(SettingsRoute(), over: .root)
path.removeLast()
```

This approach is useful when navigation is produced by reducers, domain logic,
or deterministic test fixtures.

## Nested sheet flows

When a sheet destination calls `embedInPresentation()`, the sheet gets
its own child namespace. Pushes inside that embedded stack stay isolated from
the parent presentation flow.

The embedded stack is a separate `NavigationStack`, and destinations registered
outside it are not visible inside it. Register the destinations that the sheet
needs, for pushes and for further sheets, on the content inside the sheet, before
`embedInPresentation()`:

```swift
.presentationDestination(for: Project.self) { project in
    ProjectScreen(project: project)
        .presentationDestination(for: Task.self) { task in
            TaskScreen(task: task)
        }
        .embedInPresentation()
}
```

Without the inner `presentationDestination`, a push or a nested sheet inside the
sheet finds no destination.

`@Environment(\.presentation)` read in the destination view itself still holds
the router of the parent stack. Read it inside the embedded content to get the
router of the sheet's own stack.
