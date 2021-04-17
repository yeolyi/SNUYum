//
//  ViewIf.swift
//  SNUYum
//
//  Created by SEONG YEOL YI on 2021/04/02.
//

import SwiftUI

extension View {
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
