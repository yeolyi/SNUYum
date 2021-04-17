//
//  Provider.swift
//  SNUYum
//
//  Created by SEONG YEOL YI on 2021/04/07.
//

import SwiftUI
import WidgetKit

struct Provider: IntentTimelineProvider {
    
    let sampleEntry: MenuScheduleEntry = {
        let sampleRestaurant = Restaurant.getSample()
        return MenuScheduleEntry(
            date: Date(), restaurant: sampleRestaurant, meal: .lunch,
            menus: sampleRestaurant.menus(at: .lunch)
        )
    }()
    
    func placeholder(in context: Context) -> MenuScheduleEntry {
        sampleEntry
    }
    
    func getSnapshot(
        for configuration: SelectRestaurantIntent,
        in context: Context,
        completion: @escaping (MenuScheduleEntry) -> Void
    ) {
        guard !context.isPreview else {
            completion(sampleEntry)
            return
        }
        let htmlDecoder = HTMLDecoder.shared
        guard let restaurantID = RestaurantID(widgetRestaurantID: configuration.id) else {
            // 위젯에서 선택된 식당이 코드상에 존재하지 않는 경우
            assertionFailure()
            let entry = MenuScheduleEntry()
            completion(entry)
            return
        }
        let restaurant = Restaurant(id: restaurantID)
        htmlDecoder.downloadedRestaurantMenus(at: Date().dailyDateComponents, of: restaurantID) { oneDayMenus in
            if let currentMeal = restaurant.operatingHours?.suggestedMeal(at: Date()) {
                // 오늘 추천 식당이 있는 경우
                let menus = oneDayMenus?[menusAt: currentMeal]?.compactMap {
                    Restaurant.Menu(name: $0.name, cost: $0.cost)
                }
                completion(MenuScheduleEntry(restaurant: restaurant, meal: currentMeal, menus: menus))
            } else {
                // 오늘 추천 식당이 없는 경우 - 내일 첫번째 메뉴를 선택
                let meal = restaurant.operatingHours?.nextDayFirstMeal(today: Date()) ?? .breakfast
                let menus = oneDayMenus?[menusAt: meal]?.compactMap {
                    Restaurant.Menu(name: $0.name, cost: $0.cost)
                }
                let entry = MenuScheduleEntry(restaurant: restaurant, meal: meal, menus: menus)
                completion(entry)
            }
        }
    }
    
    func getTimeline(
        for configuration: SelectRestaurantIntent,
        in context: Context,
        completion: @escaping (Timeline<MenuScheduleEntry>) -> Void
    ) {
        guard let restaurantID = RestaurantID(widgetRestaurantID: configuration.id) else {
            // 위젯에서 선택된 식당이 코드상에 존재하지 않는 경우
            let entries = [MenuScheduleEntry()]
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
            return
        }
        let restaurant = Restaurant(id: restaurantID)
        let htmlDecoder = HTMLDecoder.shared
        guard let updateInfo = restaurant.operatingHours?.todayTomorrowUpdateDates() else {
            // 오늘 내일 영업하지 않는 경우
            let midnightUpdateTime =
                Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date().add(days: 1))!
            let entries = [
                MenuScheduleEntry(restaurant: restaurant),
                MenuScheduleEntry(date: midnightUpdateTime, restaurant: restaurant, isTomorrow: true)
            ]
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
            return
        }
        // 오늘 내일 영업시간을 얻은 경우
        var entries: [MenuScheduleEntry] = []
        for info in updateInfo {
            let menuDownloadDate = info.updateTime.dailyDateComponents
            htmlDecoder.downloadedRestaurantMenus(at: menuDownloadDate, of: restaurantID) { oneDayMenus in
                var menus: [Restaurant.Menu]?
                if let meal = info.meal {
                    menus = oneDayMenus?[menusAt: meal]?.compactMap { tempMenu in
                        Restaurant.Menu(name: tempMenu.name, cost: tempMenu.cost)
                    }
                }
                entries.append(
                    MenuScheduleEntry(
                        date: info.updateTime, restaurant: restaurant,
                        meal: info.meal, menus: menus,
                        isTomorrow: info.targetDate.dailyDateComponents != Date().dailyDateComponents
                    )
                )
                if updateInfo.last == info {
                    let timeline = Timeline(entries: entries, policy: .atEnd)
                    for entry in entries {
                        print(
                            """
                            \(entry.date.description(with: Locale(identifier: "ko-kr")))
                            \(String(describing: entry.meal))
                            \(entry.menuDate.description(with: Locale(identifier: "ko-kr")))
                            -----
                            """
                        )
                    }
                    completion(timeline)
                }
            }
        }
    }
}
