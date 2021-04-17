//
//  ListSectionFont.swift
//  SNUYum
//
//  Created by SEONG YEOL YI on 2021/04/02.
//

import SwiftUI

struct ListSection: ViewModifier {
    
    let isLeftAligned: Bool
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: 20, weight: .bold))
            .if(isLeftAligned) { content in
                content
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 5)
            }
            .padding(.leading, 15)
    }
}

extension View {
    func listSection(isLeftAligned: Bool = true) -> some View {
        modifier(ListSection(isLeftAligned: isLeftAligned))
    }
}

struct ListSectionFont_Previews: PreviewProvider {
    static var previews: some View {
        Text("Section")
            .listSection()
    }
}
