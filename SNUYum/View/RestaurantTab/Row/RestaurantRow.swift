//
//  RestaurantRow.swift
//  SNUYum
//
//  Created by SEONG YEOL YI on 2021/04/02.
//

import SwiftUI

struct RestaurantRow: View {
    
    let restaurant: Restaurant
    let meal: Meal
    
    @EnvironmentObject var ratingListener: RatingListener
    
    var operatingHoursInfo: String {
        guard let status = restaurant.operatingHours?.status(at: Date()) else {
            return ""
        }
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .short
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "ko-kr")
        formatter.calendar = calendar
        switch status {
        case .close, .waitingOpen:
            return "영업 종료"
        case .open(let meal, let remaining):
            return "\(meal) 마감까지 \(formatter.string(from: remaining)!)"
        case .waiting(let meal, let remaining):
            return "\(meal) 시작까지 \(formatter.string(from: remaining)!)"
        }
    }
    
    var menus: [Restaurant.Menu]? {
        restaurant.menus(at: meal)
    }
    
    private var isTruncatedMenu: Bool {
        (menus?.count ?? 0) > 3
    }
    
    var body: some View {
        NavigationLink(destination:
                        RestaurantDetail(restaurant: restaurant)
                        .environmentObject(ratingListener)
        ) {
            VStack(spacing: 6) {
                HStack(spacing: 3) {
                    Text(restaurant.name)
                        .rowTitle()
                    Spacer()
                    Text(operatingHoursInfo)
                        .rowSubtitle()
                    Image(systemName: "chevron.right")
                        .rowSubtitle()
                }
                .padding(.bottom, 3)
                VStack(spacing: 6) {
                    ForEach(restaurant.menus(at: meal)?.prefix(3) ?? []) { menu in
                        HStack(alignment: .bottom, spacing: 5) {
                            Text(menu.name)
                                .rowBody()
                                .foregroundColor(.primary)
                                .lineLimit(1)
                            Spacer()
                            Text(menu.cost.description)
                                .rowBody()
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    if isTruncatedMenu {
                        Text("+ \((menus?.count ?? 3) - 3)개 메뉴")
                            .rowSubtitle()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                if ratingListener.totalCheckin != 0 {
                    Text("\(String(ratingListener.totalCheckin))명이 다녀갔어요.")
                        .rowSubtitle()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .rowBackground()
        .disabled(ratingListener.isLoading)
    }
}

struct RestaurantRow_Previews: PreviewProvider {
    static var previews: some View {
        let restaurant = Restaurant(id: .학생회관)
        restaurant.setDate(to: Date().dailyDateComponents, decoder: HTMLDecoder.shared) {}
        return
            NavigationView {
                RestaurantRow(restaurant: restaurant, meal: .lunch)
                    .navigationBarTitle(Text("Restaurant Row"))
            }
            .environmentObject(RestaurantUpdater())
            .environmentObject(RatingListener(authManager: AuthManager(), restaurantName: "학생회관식당"))
        
    }
}
