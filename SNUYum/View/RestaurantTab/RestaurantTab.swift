//
//  MenuView.swift
//  SNUYum
//
//  Created by SEONG YEOL YI on 2021/04/01.
//

import SwiftUI
import GoogleMobileAds

struct RestaurantTab: View {
    
    @State var showFavoritesEdit = false
    @EnvironmentObject var restaurantUpdater: RestaurantUpdater
    @EnvironmentObject var authManager: AuthManager
    
    let adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(UIScreen.main.bounds.width - 16)
    
    var downloadingNotifier: some View {
        Text("학식 정보를 받아오는 중...")
            .rowSubtitle()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 15)
            .padding(.top, 8)
    }
    
    var isDataToday: Bool {
        restaurantUpdater.dataRequestedDate.dailyDateComponents == Date().dailyDateComponents
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if !restaurantUpdater.isInternetConnected {
                        HStack {
                            Text("네트워크 상태를 확인해주세요")
                                .rowSubtitle()
                                .padding(.leading, 15)
                            Spacer()
                        }
                    }
                    if !restaurantUpdater.favorites.isEmpty {
                        VStack(spacing: 0) {
                            HStack {
                                Text("즐겨찾기")
                                    .listSection()
                                TextButton(label: "편집") {
                                    showFavoritesEdit = true
                                }
                                .padding(.trailing, 20)
                            }
                            if restaurantUpdater.isDownloading == true {
                                downloadingNotifier
                            }
                            ForEach(restaurantUpdater.favorites) { restaurant in
                                RestaurantRow(restaurant: restaurant, meal: restaurantUpdater.mealToShow)
                                    .environmentObject(
                                        RatingListener(authManager: authManager, restaurantName: restaurant.name)
                                    )
                                if restaurantUpdater.favorites.firstIndex(of: restaurant) == 1 {
                                    GoogleBannerAd()
                                        .frame(width: adSize.size.width, height: adSize.size.height)
                                        .padding(.vertical, 3)
                                }
                            }
                        }
                    }
                    VStack(spacing: 0) {
                        Text("모든 식당")
                            .listSection()
                        if restaurantUpdater.isDownloading == true {
                            downloadingNotifier
                        }
                        ForEach(restaurantUpdater.generals) { restaurant in
                            RestaurantRow(restaurant: restaurant, meal: restaurantUpdater.mealToShow)
                                .environmentObject(
                                    RatingListener(authManager: authManager, restaurantName: restaurant.name)
                                )
                            if restaurantUpdater.favorites.count <= 1
                                && restaurantUpdater.generals.firstIndex(of: restaurant) == 1 {
                                GoogleBannerAd()
                                    .frame(width: adSize.size.width, height: adSize.size.height)
                                    .padding(.vertical, 3)
                            }
                        }
                    }
                }
                .padding(.top, 10)
            }
            .padding(.top, 1)
            .sheet(isPresented: $showFavoritesEdit) {
                ReorderFavorites()
                    .environmentObject(restaurantUpdater)
            }
            .navigationBarTitle(
                Text("\(isDataToday ? "오늘" : "내일") \(restaurantUpdater.mealToShow.description)")
            )
            .navigationBarItems(trailing: MealButton())
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        let updater = RestaurantUpdater()
        RestaurantTab()
            .environmentObject(updater)
            .environmentObject(AuthManager())
    }
}
