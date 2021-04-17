//
//  SettingTab.swift
//  SNUYum
//
//  Created by SEONG YEOL YI on 2021/04/04.
//

import SwiftUI

struct SettingTab: View {
    
    @EnvironmentObject var restaurantUpdater: RestaurantUpdater
    @EnvironmentObject var authManager: AuthManager
    
    @State var showAskLogin = false
    
    var body: some View {
        NavigationView {
            List {
                Section(
                    header: Text("표시"),
                    footer: Text("시간에 따라 아침/점심/저녁 메뉴를 자동으로 보여드려요.")
                ) {
                    NavigationLink(destination: SuggestionChooser()) {
                        HStack {
                            Text("시간별 추천 기준")
                            Spacer()
                            Text(Restaurant(id: restaurantUpdater.timelyMealStandard).name)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                Section(
                    header: Text("계정"),
                    footer: Text("스누냠의 모든 기능을 사용해보세요.")
                ) {
                    if authManager.isLoggedIn {
                        Text(authManager.userEmail ?? "")
                        Button(action: {
                            authManager.signOut()
                        }) {
                            Text("로그아웃")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    } else {
                        Button(action: { showAskLogin = true }) {
                            Text("로그인")
                        }
                    }
                }
                Section(header: Text("디버그")) {
                    Button(action: restaurantUpdater.clear) {
                        Text("저장된 식단 삭제")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle(Text("설정"))
            .sheet(isPresented: $showAskLogin) {
                AskLoginModal()
                    .environmentObject(authManager)
                    .environmentObject(restaurantUpdater)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct SettingTab_Previews: PreviewProvider {
    static var previews: some View {
        SettingTab()
            .environmentObject(RestaurantUpdater())
            .environmentObject(AuthManager())
    }
}
