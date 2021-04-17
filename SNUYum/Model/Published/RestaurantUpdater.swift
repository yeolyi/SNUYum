//
//  RestaurantUpdater.swift
//  SNUYum
//
//  Created by SEONG YEOL YI on 2021/04/01.
//

import SwiftUI
import Network

/// Restaurant 객체들의 정보 및 표시 방법을 관리합니다.
class RestaurantUpdater: ObservableObject {
    
    @Published private var contents: Set<Restaurant> = []
    @Published private(set) var mealToShow: Meal = .lunch
    @Published private(set) var isDownloading = false
    @Published private(set) var isInternetConnected = false
    
    let monitor = NWPathMonitor()
    
    private(set) var dataRequestedDate = Date()
    
    @AutoSave("mealViewMode", defaultValue: .auto)
    private(set) var mealViewMode: MealViewMode {
        didSet {
            objectWillChange.send()
        }
    }
    
    @AutoSave("favoritesOrder", defaultValue: [])
    var favoritesOrder: [RestaurantID] {
        didSet {
            objectWillChange.send()
        }
    }
    
    @AutoSave("mealViewModeStandard", defaultValue: .학생회관)
    var timelyMealStandard: RestaurantID {
        didSet {
            update()
        }
    }
    
    @AutoSave("timerCafeName", defaultValue: "학생회관식당")
    private var alimiCafeName: String?
    
    @AutoSave("cafeList", defaultValue: [])
    private var cafeList: [ListElement]
    
    @AutoSave("firstRun", defaultValue: true)
    private var isFirstRun: Bool
    
    var favorites: [Restaurant] {
        favoritesOrder.compactMap { id in
            contents.first(where: {$0.id == id})
        }.filter {
            $0.menus(at: mealToShow)?.isEmpty == false
        }
    }
    
    var generals: [Restaurant] {
        contents.filter {
            !$0.isFavorite && $0.menus(at: mealToShow)?.isEmpty == false
        }.sorted(by: { $0.id < $1.id })
    }
    
    func clear() {
        contents = []
        htmlDecoder.clear()
        update()
    }
    
    func changeFavoriteValue(of restaurant: Restaurant, into isFavorite: Bool) {
        restaurant.setIsFavoriteOnUpdater(to: isFavorite)
        if isFavorite {
            if !favoritesOrder.contains(restaurant.id) {
                favoritesOrder.append(restaurant.id)
            }
        } else {
            favoritesOrder.removeAll(where: { $0 == restaurant.id })
        }
        objectWillChange.send()
    }
    
    func setDate(to date: Date) {
        dataRequestedDate = date
        if htmlDecoder.willDownload(at: dataRequestedDate.dailyDateComponents) {
            isDownloading = true
        }
        print(isDownloading)
        htmlDecoder.allRestaurantIDs(at: dataRequestedDate.dailyDateComponents) { ids in
            DispatchQueue.main.async {
                withAnimation {
                    for id in ids {
                        let restaurant = Restaurant(id: id)
                        self.contents.insert(restaurant)
                    }
                    let restaurantArr = Array(self.contents)
                    for restaurant in restaurantArr {
                        restaurant.setDate(
                            to: self.dataRequestedDate.dailyDateComponents,
                            decoder: self.htmlDecoder
                        ) {
                            restaurant.setIsFavoriteOnUpdater(to: self.favoritesOrder.contains(restaurant.id))
                            if restaurant == restaurantArr.last {
                                self.isDownloading = false
                                self.objectWillChange.send()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func rotateMealViewMode() {
        setMealViewMode(to: mealViewMode.rotatingNext)
    }
    
    init() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                if path.status == .satisfied {
                    self.isInternetConnected = true
                } else {
                    self.isInternetConnected = false
                }
                self.update()
            }
        }
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
        if isFirstRun, let alimiCafeName = alimiCafeName {
            print("이전 설정 복구 중,,,")
            timelyMealStandard = .init(alimiCafeName)
            favoritesOrder = cafeList.filter(\.isFixed).map {
                RestaurantID($0.name)
            }
            isFirstRun = false
        }
        update()
    }
    
    func update() {
        setMealViewMode(to: mealViewMode)
    }
    
    private let htmlDecoder = HTMLDecoder.shared
    
    private func setMealViewMode(to mode: MealViewMode) {
        let restaurant = Restaurant(id: timelyMealStandard)
        let status = restaurant.operatingHours?.status(at: Date())
        var targetDate = Date()
        var isTomorrow = false
        if case .close = status {
            targetDate = targetDate.add(days: 1)
            isTomorrow = true
        }
        setDate(to: targetDate)
        switch mode {
        case .breakfast:
            mealToShow = .breakfast
        case .lunch:
            mealToShow = .lunch
        case .dinner:
            mealToShow = .dinner
        case .auto:
            if let operatingHour = restaurant.operatingHours {
                if isTomorrow {
                    mealToShow = operatingHour.nextDayFirstMeal(today: Date()) ?? .lunch
                    self.mealViewMode = mode
                    return
                }
                if let mealToShow = operatingHour.suggestedMeal(at: targetDate) {
                    // 식당이 운영하며 시간별 추천 식당이 있는 경우
                    self.mealToShow = mealToShow
                } else {
                    // 식당이 운영하지만 영업이 끝난 경우 - 모순
                    mealToShow = defaultSuggestedMeal(at: targetDate) ?? .breakfast
                }
            } else {
                // 식당이 운영하지 않는 경우
                mealToShow = .lunch
            }
        }
        self.mealViewMode = mode
    }
}

private struct ListElement: Hashable, Codable, Identifiable {
    var id = UUID()
    /// Cafe's name
    var name: String = ""
    /// Always show cafe on the top of the list
    var isFixed: Bool = false
    /// Show cafe in list
    var isShown: Bool = true
}
