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
                presentation?.present(value: SettingsRoute())
            }

            Button("Push details") {
                presentation?.push(value: RelatedUserRoute())
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
