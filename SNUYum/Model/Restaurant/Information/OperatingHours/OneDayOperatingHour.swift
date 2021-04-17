//
//  OneDayOperatingHur.swift
//  SNUYum
//
//  Created by SEONG YEOL YI on 2021/04/07.
//

import Foundation

/// 하루동안의 끼니별 운영시간을 표현합니다.
struct OneDayOperatingHour {
    
    /// 입력된 일자에 입력된 끼니에 해당하는 식당 마감 시간을 반환합니다.
    /// - Returns: 운영하지 않으면 nil을 반환합니다.
    func closeTime(of meal: Meal, at date: Date) -> Date? {
        storage[meal]?.close.matchingDatePoint(at: date)
    }
    
    var firstMeal: Meal? {
        storage.keys.sorted().first
    }
    
    /// - Note: 5시 이전을 waitingOpen으로 정의합니다.
    func status(at date: Date) -> OperatingHourStatus {
        if date.hour < 5 {
            return .waitingOpen
        }
        for meal in Meal.allCases {
            guard let openCloseTime = storage[meal] else {
                continue
            }
            switch openCloseTime.position(of: date) {
            case .before:
                guard let remainTime = openCloseTime.remainingTime(from: date) else {
                    break
                }
                return .waiting(meal: meal, remaining: remainTime)
            case .contains:
                guard let remainTime = openCloseTime.remainingTime(from: date) else {
                    break
                }
                return .open(meal: meal, remaining: remainTime)
            case .after:
                break
            }
        }
        return .close
    }
    
    func description(at meal: Meal) -> String? {
        Meal.lunchDinnerConvertable(meal, target: { storage[$0] != nil }) { state in
            switch state {
            case .onlyLunchDinner:
                return storage[.lunchDinner]?.description
            case .noLunchDinner:
                return (storage[.lunch]?.description ?? "") + " / " + (storage[.dinner]?.description ?? "")
            case .default:
                return storage[meal]?.description
            }
        }
    }
    
    /// - Important: 배열의 모든 원소가 OneCloseTime의 이니셜라이저 조건을 만족시켜야 하며 원소의 수는 3개(아침, 점심, 저녁)이어야 합니다.
    /// - Note: 점심과 저녁 운영시간이 같으면 lunchdinner로 치환하여 저장합니다.
    init?(_ oneDayRaw: [String?]) {
        guard oneDayRaw.count == 3 else {
            return nil
        }
        var tempStorage: [Meal: OpenCloseTime] = [:]
        for (index, meal) in [Meal.breakfast, Meal.lunch, Meal.dinner].enumerated() {
            if let openCloseTimeRaw = oneDayRaw[index],
               let openCloseTime = OpenCloseTime(openCloseTimeRaw) {
                tempStorage[meal] = openCloseTime
            }
        }
        if tempStorage[.lunch] == tempStorage[.dinner] {
            tempStorage[.lunchDinner] = tempStorage[.lunch]
            tempStorage[.lunch] = nil
            tempStorage[.dinner] = nil
        }
        storage = tempStorage
    }
    
    private let storage: [Meal: OpenCloseTime]
}
