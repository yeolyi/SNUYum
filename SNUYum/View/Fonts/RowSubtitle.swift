//
//  RowSubtitle.swift
//  SNUYum
//
//  Created by SEONG YEOL YI on 2021/04/02.
//

import SwiftUI

struct RowSubtitle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.secondary)
    }
}

extension View {
    func rowSubtitle() -> some View {
        modifier(RowSubtitle())
    }
}

struct RowSubtitle_Previews: PreviewProvider {
    static var previews: some View {
        Text("RowSubtitle")
            .rowSubtitle()
    }
}
