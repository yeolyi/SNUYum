//
//  NavigationIcon.swift
//  SNUYum
//
//  Created by SEONG YEOL YI on 2021/04/04.
//

import SwiftUI

struct NavigationIcon: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 25, weight: .medium))
            .foregroundColor(.brand)
    }
}

extension View {
    func navigationIcon() -> some View {
        modifier(NavigationIcon())
    }
}

struct NavigationIcon_Previews: PreviewProvider {
    static var previews: some View {
        Text("Navigation Icon")
            .navigationIcon()
    }
}
