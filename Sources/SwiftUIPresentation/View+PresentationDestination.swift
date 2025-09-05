//
//  View+PresentationDestination.swift
//  SwiftUIPresentation
//
//  Created by Valeriy Malishevskyi on 05.09.2025.
//

import SwiftUI

extension View {
    /// Registers a view to show when presenting values of a specific type.
    ///
    /// Call this method inside a ``PresentationStack`` to tell the system what
    /// view to display when navigation targets a particular data type. Both
    /// stack pushes and sheet presentations use the same destination.
    ///
    /// You can register multiple destinations for different types:
    /// ```swift
    /// PresentationStack {
    ///     // Navigation content
    ///     .presentationDestination(for: User.self) { user in
    ///         UserProfile(user: user)
    ///     }
    ///     .presentationDestination(for: Article.self) { article in
    ///         ArticleView(article: article)
    ///     }
    /// }
    /// ```
    public func presentationDestination<D, C>(
        for data: D.Type,
        @ViewBuilder destination: @escaping (D) -> C
    ) -> some View where D : Hashable, C : View {
        self.modifier(PresentationDestinationStackModifier(data: data, destination: destination))
            .modifier(PresentationDestinationSheetModifier(data: data, destination: destination))
    }
}

