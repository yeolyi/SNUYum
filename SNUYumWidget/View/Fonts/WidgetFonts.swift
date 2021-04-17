//
//  WidgetFonts.swift
//  SNUYum
//
//  Created by SEONG YEOL YI on 2021/04/08.
//

import SwiftUI

struct WidgetTitle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(.headline))
            .foregroundColor(.white)
    }
}

extension View {
    func widgetTitle() -> some View {
        modifier(WidgetTitle())
    }
}

struct WidgetSubtitle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(Color(hex: "AAAAAA"))
    }
}

extension View {
    func widgetSubtitle() -> some View {
        modifier(WidgetSubtitle())
    }
}

struct WidgetBody: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 15, weight: .semibold))
            .foregroundColor(.secondary)
    }
}

extension View {
    func widgetBody() -> some View {
        modifier(WidgetBody())
    }
}

struct WidgetCaption: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 12))
            .foregroundColor(.secondary)
    }
}

extension View {
    func widgetCaption() -> some View {
        modifier(WidgetCaption())
    }
}
