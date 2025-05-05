//
//  ClearNavigationBar.swift
//  Hearth
//
//  Created by Aaron McKain on 3/23/25.
//

/*
import SwiftUI

struct ClearNavigationBar: ViewModifier {
    var backgroundColor: UIColor?
    var titleFont: UIFont?
    var titleColor: UIColor?

    init(backgroundColor: UIColor? = nil, titleFont: UIFont? = nil, titleColor: UIColor? = nil) {
        self.backgroundColor = backgroundColor
        self.titleFont = titleFont
        self.titleColor = titleColor

        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = backgroundColor
        appearance.shadowColor = .clear

        // Set larger inline title font here
        if let titleFont = titleFont, let titleColor = titleColor {
            appearance.titleTextAttributes = [
                .font: titleFont,
                .foregroundColor: titleColor
            ]
        }

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }

    func body(content: Content) -> some View {
        content
    }
}


extension View {
    func navigationBarClearBackground(
        _ color: UIColor? = nil,
        titleFont: UIFont? = nil,
        titleColor: UIColor? = nil
    ) -> some View {
        self.modifier(
            ClearNavigationBar(
                backgroundColor: color,
                titleFont: titleFont,
                titleColor: titleColor
            )
        )
    }
}
*/

