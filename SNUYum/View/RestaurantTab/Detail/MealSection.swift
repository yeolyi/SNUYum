//
//  MealDetail.swift
//  SNUYum
//
//  Created by SEONG YEOL YI on 2021/04/03.
//

import SwiftUI

struct MealSection: View {
    
    @EnvironmentObject var ratingListener: RatingListener
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var restaurantUpdater: RestaurantUpdater
    
    @State private var oneDayLimitAlert = false
    
    @Binding var activeSheet: ActiveSheet?
    
    let restaurant: Restaurant
    let meal: Meal
    
    var notices: String? {
        if let notices = restaurant.notices(at: meal) {
            if !notices.isEmpty {
                return notices.joined(separator: " / ")
            }
        }
        return nil
    }
    
    var body: some View {
        VStack(spacing: 5) {
            HStack(alignment: .bottom, spacing: 5) {
                Text(meal.description)
                    .listSection(isLeftAligned: false)
                Text(restaurant.operatingHours?.description(at: Date(), meal: meal) ?? "")
                    .rowSubtitle()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            VStack(spacing: 0) {
                ForEach(restaurant.menus(at: meal) ?? []) { menu in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(menu.name)
                                .rowBody()
                                .fixedSize(horizontal: false, vertical: true)
                            if ratingListener.totalMenuCheckin(in: menu.name) != 0 {
                                Text("\(ratingListener.totalMenuCheckin(in: menu.name))명이 냠했어요")
                                    .rowSubtitle()
                            }
                        }
                        Spacer()
                        Text(menu.cost.detailDescription)
                            .rowBody()
                            .foregroundColor(.secondary)
                        Button(action: {
                            do {
                                try ratingListener.toggleCheckin(to: menu.name)
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                            } catch {
                                switch error {
                                case RatingErrors.notLogined:
                                    activeSheet = ActiveSheet.login
                                case RatingErrors.oneDayLimit:
                                    oneDayLimitAlert = true
                                default:
                                    break
                                }
                            }
                        }) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(ratingListener.isCheckined(in: menu.name) ? Color.brand : .secondary)
                                .opacity(ratingListener.isCheckined(in: menu.name) ? 1.0 : 0.5)
                                .frame(width: 30, height: 30)
                        }
                    }
                    if menu != restaurant.menus(at: meal)?.last {
                        Divider()
                            .padding(.vertical, 12)
                    }
                }
            }
            .rowBackground()
            if notices != nil {
                Text(notices!)
                    .font(.system(.subheadline))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 20)
            }
        }
        .alert(isPresented: $oneDayLimitAlert) {
            Alert(title: Text("횟수 초과 :("), message: Text("하루에 네가지 메뉴를 체크할 수 있어요."), dismissButton: .default(Text("닫기")))
        }
    }
}

struct MealDetail_Previews: PreviewProvider {
    static var previews: some View {
        let restaurant = Restaurant(id: .학생회관)
        restaurant.setDate(to: Date().dailyDateComponents, decoder: HTMLDecoder.shared) {}
        return MealSection(activeSheet: .constant(nil), restaurant: restaurant, meal: .lunch)
            .environmentObject(RatingListener(authManager: AuthManager(), restaurantName: "학생회관식당"))
    }
}
