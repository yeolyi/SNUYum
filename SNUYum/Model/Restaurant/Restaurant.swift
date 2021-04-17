//
//  Restaurant.swift
//  SNUYum
//
//  Created by SEONG YEOL YI on 2021/03/29.
//

import SwiftUI

/// 식당 한 개의 메뉴와 정보를 제공합니다.
class Restaurant: Identifiable, ObservableObject {
    
    let id: RestaurantID
    
    @Published private(set) var isFavorite: Bool
    
    var sortedAccessableMeals: [Meal]? {
        oneDayMenus?.availableMeals.sorted()
    }
    
    /// 클래스가 반환하는 메뉴와 운영시간의 기준 날짜를 설정합니다.
    func setDate(to dateComponents: DateComponents, decoder: HTMLDecoder, completion: @escaping () -> Void) {
        decoder.downloadedRestaurantMenus(at: dateComponents, of: id) {
            self.oneDayMenus = $0
            completion()
        }
    }
    
    func setIsFavoriteOnUpdater(to isFavorite: Bool) {
        self.isFavorite = isFavorite
    }
    
    func menus(at meal: Meal) -> [Menu]? {
        oneDayMenus?[menusAt: meal]?.map {
            Menu(name: $0.name, cost: $0.cost)
        }
    }
    
    func notices(at meal: Meal) -> [String]? {
        oneDayMenus?[noticesAt: meal]
    }
    
    struct Menu: Identifiable, Equatable {
        var id: String {
            "\(name)\(cost)"
        }
        let name: String
        let cost: Cost
        
        init(name: String, cost: Cost) {
            self.name = name
            self.cost = cost
        }
    }
    
    init(id: RestaurantID) {
        self.id = id
        isFavorite = false
    }
    
    private var oneDayMenus: OneDayMenus?
}

extension Restaurant: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Restaurant, rhs: Restaurant) -> Bool {
        lhs.id == rhs.id
    }
}

extension Restaurant {
    static func getSample() -> Restaurant {
        let sample = Restaurant(id: .학생회관)
        sample.oneDayMenus = OneDayMenus(
            id: .학생회관,
            contents: [
                .breakfast: [.init(name: "콩나물국밥", cost: .exactly(cost: 2200))],
                .lunch: [.init(name: "돌솥두부찌개", cost: .exactly(cost: 3500)),
                         .init(name: "마늘보쌈&해물파전", cost: .exactly(cost: 6000))
                ],
                .dinner: [.init(name: "치즈한장부대찌개", cost: .exactly(cost: 3500))]
            ]
        )
        return sample
    }
}
