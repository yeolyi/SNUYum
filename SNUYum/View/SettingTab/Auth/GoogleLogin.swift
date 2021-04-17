//
//  GoogleLogin.swift
//  SNUYum
//
//  Created by SEONG YEOL YI on 2021/04/11.
//

import SwiftUI
import GoogleSignIn

struct GoogleLogin: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: {
            GIDSignIn.sharedInstance().presentingViewController =
                UIApplication.shared.windows.first?.rootViewController
            GIDSignIn.sharedInstance()?.signIn()
        }) {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .foregroundColor(.white)
                        .frame(width: 22, height: 22)
                    Image("GoogleLogo")
                        .resizable()
                        .frame(width: 15, height: 15)
                }
                Text("Google로 로그인")
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 50)
        .background(Color(hex: "#4285F4"))
        .cornerRadius(5)
    }
}

struct GoogleLogin_Previews: PreviewProvider {
    static var previews: some View {
        GoogleLogin()
    }
}
