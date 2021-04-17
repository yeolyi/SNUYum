//
//  NavigationText.swift
//  SNUYum
//
//  Created by SEONG YEOL YI on 2021/04/04.
//

import SwiftUI

struct NavigationText: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.brand)
    }
}

extension View {
    func navigationText() -> some View {
        modifier(NavigationText())
    }
}

struct NavigationText_Previews: PreviewProvider {
    static var previews: some View {
        Text("Navigation Text")
            .navigationText()
    }
}
