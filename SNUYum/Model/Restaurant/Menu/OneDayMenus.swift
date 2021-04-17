//
//  DownloadedRestaurant.swift
//  SNUYum
//
//  Created by SEONG YEOL YI on 2021/03/31.
//

import Foundation

/// 식당의 하루 메뉴를 끼니별로 관리합니다.
struct OneDayMenus {
    
    let id: RestaurantID
    
    init(id: RestaurantID, contents: [Meal: [MenuNoticeWrapper]]) {
        self.id = id
        self.contents = contents
    }
    
    subscript(menusAt meal: Meal) -> [(name: String, cost: Cost)]? {
        let allMenus = contents.mapValues {
            $0.compactMap(\.menu)
        }
        return Meal.lunchDinnerConvertable(meal, target: { allMenus[$0] != nil }) { state in
            switch state {
            case .noLunchDinner:
                return Date().hour > 15 ? allMenus[.dinner] : allMenus[.lunch]
            case .onlyLunchDinner:
                return allMenus[.lunchDinner]
            case .default:
                return allMenus[meal]
            }
        }
    }
    
    subscript(noticesAt meal: Meal) -> [String]? {
        contents[meal]?.compactMap(\.notice)
    }
    
    var availableMeals: [Meal] {
        Array(contents.keys)
    }

    private let contents: [Meal: [MenuNoticeWrapper]]
}

extension OneDayMenus: CustomStringConvertible {
    var description: String {
        let name = Restaurant(id: id).name
        let menuSorted = contents.sorted(by: { $0.key < $1.key }).map { meal, menus in
            "\(meal): \(menus)"
        }.joined(separator: "\n")
        return """

    --- \(name) ---
    \(menuSorted)

    """
    }
}

extension OneDayMenus: Codable {
    
}
