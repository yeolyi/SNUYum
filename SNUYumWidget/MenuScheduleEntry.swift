//
//  MenuScheduleEntry.swift
//  SNUYum
//
//  Created by SEONG YEOL YI on 2021/04/08.
//

import WidgetKit

struct MenuScheduleEntry: TimelineEntry {
    let date: Date
    let restaurant: Restaurant?
    let meal: Meal?
    let menuDate: Date
    let menuDownloaded: [Restaurant.Menu]?
    
    init(
        date: Date = Date(), restaurant: Restaurant? = nil,
        meal: Meal? = nil, menus: [Restaurant.Menu]? = nil,
        isTomorrow: Bool = false
    ) {
        self.date = date
        self.restaurant = restaurant
        self.meal = meal
        menuDate = isTomorrow ? date.add(days: 1) : date
        menuDownloaded = menus
    }
}
