//
//  DetailRestaurant.swift
//  SNUYum
//
//  Created by SEONG YEOL YI on 2021/04/03.
//

import SwiftUI

enum ActiveSheet: Identifiable {
    case map, login
    
    var id: Int {
        hashValue
    }
}

struct RestaurantDetail: View {
    
    @ObservedObject var restaurant: Restaurant
    
    @EnvironmentObject var restaurantUpdater: RestaurantUpdater
    @EnvironmentObject var ratingListener: RatingListener
    @EnvironmentObject var authManager: AuthManager
    
    @Environment(\.colorScheme) var colorScheme
    
    @State var tempIsFavorite: Bool
    @State private var activeSheet: ActiveSheet?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                ForEach(restaurant.sortedAccessableMeals ?? []) { meal in
                    MealSection(activeSheet: $activeSheet, restaurant: restaurant, meal: meal)
                }
                if restaurant.info != nil {
                    infoSection
                }
                if restaurant.location != nil {
                    VStack(spacing: 0) {
                        HStack(alignment: .bottom) {
                            Text("위치")
                                .listSection()
                            TextButton(label: "자세히 보기") {
                                activeSheet = ActiveSheet.map
                            }
                            .padding(.trailing, 20)
                        }
                        NaverMap(restaurant: restaurant, isCompact: true)
                            .disabled(true)
                            .frame(height: 200)
                            .cornerRadius(8)
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
            }
            .padding(.top, 20)
        }
        .sheet(item: $activeSheet) { sheetType in
            switch sheetType {
            case .map:
                DetailMap(restaurant: restaurant)
            case .login:
                AskLoginModal()
                    .environmentObject(authManager)
                    .environmentObject(restaurantUpdater)
            }
        }
        .padding(.top, 1)
        .navigationBarTitle(Text(restaurant.name))
        .navigationBarItems(trailing: favoriteButton)
        .onDisappear(perform: saveChangeOnExit)
    }
    
    init(restaurant: Restaurant) {
        self.restaurant = restaurant
        _tempIsFavorite = State(initialValue: restaurant.isFavorite)
    }
    
    private func saveChangeOnExit() {
        withAnimation {
            restaurantUpdater.changeFavoriteValue(of: restaurant, into: tempIsFavorite)
        }
    }
    
    private var infoSection: some View {
        VStack(spacing: 0) {
            HStack(alignment: .bottom) {
                Text("정보")
                    .listSection()
                if restaurant.isCallAvailable {
                    TextButton(label: "전화 걸기") {
                        restaurant.call()
                    }
                    .padding(.trailing, 20)
                }
            }
            Text(restaurant.info ?? "")
                .rowBody()
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity)
                .rowBackground()
        }
    }
    
    private var favoriteButton: some View {
        Button(action: { tempIsFavorite.toggle() }) {
            Image(systemName: tempIsFavorite ? "star.fill": "star")
                .navigationIcon()
        }
    }
}

struct DetailRestaurant_Previews: PreviewProvider {
    static var previews: some View {
        let restaurant = Restaurant(id: .학생회관)
        restaurant.setDate(to: Date().dailyDateComponents, decoder: HTMLDecoder.shared) {}
        return
            NavigationView {
                RestaurantDetail(restaurant: restaurant)
            }
            .environmentObject(RestaurantUpdater())
            .environmentObject(RatingListener(authManager: AuthManager(), restaurantName: "학생회관식당"))
    }
}
