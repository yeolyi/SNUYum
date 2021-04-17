//
//  AskLoginModal.swift
//  SNUYum
//
//  Created by SEONG YEOL YI on 2021/04/12.
//

import SwiftUI

struct AskLoginModal: View {
    
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.presentationMode) var presentationMode
    @State private var isButtonVisible = false
    
    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 5) {
                Text("맛있는 밥,")
                    .font(.system(size: 45, weight: .heavy))
                    .offset(y: isButtonVisible ? 0 : 10)
                    .opacity(isButtonVisible ? 1 : 0)
                    .transition(.move(edge: .leading))
                Text("즐거운 대학생활")
                    .foregroundColor(Color.brand)
                    .font(.system(size: 45, weight: .heavy))
                    .offset(y: isButtonVisible ? 0 : 10)
                    .opacity(isButtonVisible ? 1 : 0)
                    .animation(Animation.default.delay(0.9))
                    .transition(.move(edge: .leading))
            }
            .padding(.bottom, 8)
            Text("😋")
                .font(.system(size: 70))
                .padding(.bottom, 50)
                .opacity(isButtonVisible ? 1 : 0)
                .animation(Animation.default.delay(1.4))
            Spacer()
            Text("맛있는 학식으로의 여정을 지금 함께하세요 :)")
                .font(.system(size: 15, weight: .semibold))
                .opacity(isButtonVisible ? 1 : 0)
                .animation(Animation.default.delay(2))
                .transition(.move(edge: .top))
                .offset(y: isButtonVisible ? 0 : 10)
            SignInWithAppleToFirebase { state in
                if state == .success {
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 50)
            GoogleLogin()
            Text("로그인 정보는 개인 식별을 위해 사용됩니다.")
                .rowSubtitle()
                .padding(.top, 10)
                .opacity(0.5)
        }
        .padding(10)
        .onReceive(authManager.objectWillChange) {
            presentationMode.wrappedValue.dismiss()
        }
        .onAppear {
            withAnimation(Animation.default.delay(0.4)) {
                    isButtonVisible = true
                }
        }
    }
}

struct AskLoginModal_Previews: PreviewProvider {
    static var previews: some View {
        Text("")
            .sheet(isPresented: .constant(true)) {
                AskLoginModal()
                    .environmentObject(AuthManager())
                    .environmentObject(RestaurantUpdater())
            }
    }
}
