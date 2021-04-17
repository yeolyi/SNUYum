//
//  RowBackground.swift
//  SNUYum
//
//  Created by SEONG YEOL YI on 2021/04/02.
//

import SwiftUI

struct RowBackground: ViewModifier {
    
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .padding(15)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .if(colorScheme == .light) {
                        $0.foregroundColor(.white)
                            .shadow(
                                color: Color.gray.opacity(0.6),
                                radius: 1.8, y: 1.28
                            )
                    }
                    .if(colorScheme == .dark) {
                        $0.foregroundColor(Color.gray.opacity(0.15))
                    }
            )
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
    }
}

extension View {
    func rowBackground() -> some View {
        modifier(RowBackground())
    }
}

struct RowBackground_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                Text("RowBackground")
                    .rowBackground()
            }
            .environment(\.colorScheme, .light)
        }
        Group {
            NavigationView {
                Text("RowBackground")
                    .rowBackground()
            }
            .environment(\.colorScheme, .dark)
        }
    }
}
