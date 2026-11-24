/// The modal host used for a presented destination.
public enum PresentationHost: Hashable, Sendable {
    /// Presents the destination as a standard sheet.
    case sheet
    /// Presents the destination as a popover where the platform supports it.
    case popover
    /// Presents the destination as a full-screen cover on iOS.
    ///
    /// On macOS and older runtimes this host falls back to a sheet.
    case fullScreenCover
}
