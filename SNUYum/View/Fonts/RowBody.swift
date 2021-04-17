//
//  RowBody.swift
//  SNUYum
//
//  Created by SEONG YEOL YI on 2021/04/02.
//

import SwiftUI

struct RowBody: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 16, weight: .medium))
    }
}

extension View {
    func rowBody() -> some View {
        modifier(RowBody())
    }
}

struct RowBody_Previews: PreviewProvider {
    static var previews: some View {
        Text("RowBody")
            .rowBody()
    }
}
