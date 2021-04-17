//
//  RowTitle.swift
//  SNUYum
//
//  Created by SEONG YEOL YI on 2021/04/02.
//

import SwiftUI

struct RowTitle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(Color.brand)
    }
}

extension View {
    func rowTitle() -> some View {
        modifier(RowTitle())
    }
}

struct RowTitle_Previews: PreviewProvider {
    static var previews: some View {
        Text("Section")
            .rowTitle()
    }
}
