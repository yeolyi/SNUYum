//
//  TextButton.swift
//  SNUYum
//
//  Created by SEONG YEOL YI on 2021/04/04.
//

import SwiftUI

struct TextButton: View {
    
    let action: () -> Void
    let label: String
    
    init(label: String, action: @escaping () -> Void) {
        self.label = label
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 16))
                .foregroundColor(.blue)
                .frame(height: 30)
        }
    }
}

struct TextButton_Previews: PreviewProvider {
    static var previews: some View {
        TextButton(label: "Tap Here", action: {})
    }
}
