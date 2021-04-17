//
//  OperatingHours.swift
//  SNUYum
//
//  Created by SEONG YEOL YI on 2021/03/27.
//

import Foundation

/// 식단 업데이트 시점의 정보를 저장합니다.
struct TimelyUpdate: Equatable {
    let updateTime: Date
    let meal: Meal?
    let targetDate: Date
}

/// 한 식당의 운영시간을 표현합니다.
struct OperatingHours {
    
    func description(at date: Date, meal: Meal) -> String? {
        storage[DayOfTheWeekType(date: date)]?.description(at: meal)
    }
    
    func status(at date: Date) -> OperatingHourStatus {
        oneDayOperatingHour(at: date)?.status(at: date) ?? .close
    }
    
    /// - Returns: 당일 영업 종료시 nil 반환
    func suggestedMeal(at date: Date) -> Meal? {
        switch status(at: date) {
        case .close:
            return nil
        case .waitingOpen:
            return .breakfast
        case .open(let meal, _), .waiting(let meal, _):
            if meal == .lunchDinner {
                return date.hour > 15 ? .dinner : .lunch
            }
            return meal
        }
    }
    
    func nextDayFirstMeal(today: Date) -> Meal? {
        oneDayOperatingHour(at: today.add(days: 1))?.firstMeal
    }
    
    private func oneDayOperatingHour(at date: Date) -> OneDayOperatingHour? {
        let operatingHourType = DayOfTheWeekType(date: date)
        return storage[operatingHourType]
    }
    
    /// 평일, 토요일, 일요일순으로 OneDayOperatingHour의 이니셜라이저에 맞는 배열을 요구합니다. 원소 수는 무조건 3개여야 합니다.
    init(_ raw: [[String?]?]) {
        guard raw.count == 3 else {
            storage = [:]
            return
        }
        storage = DayOfTheWeekType.allCases.reduce(into: [:]) { result, type in
            if let raw = raw[type.rawValue] {
                result[type] = OneDayOperatingHour(raw)
            }
        }
    }
    
    private let storage: [DayOfTheWeekType: OneDayOperatingHour]
}

func defaultSuggestedMeal(at date: Date) -> Meal? {
    switch date.hour {
    case 0..<10:
        return .breakfast
    case 10..<15:
        return .lunch
    case 15..<19:
        return .dinner
    default:
        return nil
    }
}

extension OperatingHours {
    /// 오늘과 내일 중 식단 메뉴가 바뀌는 시점을 반환합니다. 함수 호출 시점을 포함.
    func todayTomorrowUpdateDates() -> [TimelyUpdate] {
        let calendar = Calendar.current
        var temp: [TimelyUpdate] = []
        switch status(at: Date()) {
        case .close:
            if let nextDayFirstMeal = nextDayFirstMeal(today: Date()) {
                // 내일 메뉴가 있는 경우
                temp.append(
                    .init(updateTime: Date(), meal: nextDayFirstMeal, targetDate: Date().add(days: 1))
                )
            } else {
                // 내일도 비어있는 경우
                temp.append(
                    .init(updateTime: Date(), meal: nil, targetDate: Date().add(days: 1))
                )
            }
        case .open(let meal, _), .waiting(let meal, _):
            // 오픈 중이거나 오픈을 기다리는 경우
            temp.append(.init(updateTime: Date(), meal: meal, targetDate: Date()))
            temp.append(contentsOf: oneDaySchedule(current: meal, at: Date()))
        case .waitingOpen:
            if let suggested = suggestedMeal(at: Date()) {
                // 오늘 메뉴가 있는 경우
                temp.append(.init(updateTime: Date(), meal: suggested, targetDate: Date()))
                temp.append(contentsOf: oneDaySchedule(current: suggested, at: Date()))
            } else {
                // 오늘 메뉴가 없는 경우
                temp.append(.init(updateTime: Date(), meal: nil, targetDate: Date().add(days: 1)))
            }
        }
        // 오늘 내일 업데이트 시점이 한 곳(지금)뿐이면 내일 자정에 다시 업데이트 시도
        if temp.count == 1 {
            let tomorrowSchedule = oneDaySchedule(current: .breakfast, at: Date().add(days: 1))
            if tomorrowSchedule.isEmpty {
                let nextDateUpdateTime = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: Date().add(days: 1))!
                temp.append(.init(updateTime: nextDateUpdateTime, meal: nil, targetDate: Date().add(days: 1)))
            } else {
                temp.append(contentsOf: tomorrowSchedule)
            }
        }
        return temp
    }
    
    /// 입력된 하루동안 남아있는 업데이트 시점을 반환합니다
    /// - Parameters:
    ///   - startsFrom: 현재 대기중이거나 시작한 끼니
    func oneDaySchedule(current: Meal, at date: Date) -> [TimelyUpdate] {
        var temp: [TimelyUpdate] = []
        switch current {
        case .breakfast:
            if let breakfastEndTime = oneDayOperatingHour(at: date)?.closeTime(of: .breakfast, at: date) {
                temp.append(
                    .init(updateTime: breakfastEndTime, meal: .lunch, targetDate: date)
                )
            }
            fallthrough
        case .lunch:
            if let lunchEndTime = oneDayOperatingHour(at: Date())?.closeTime(of: .lunch, at: date) {
                temp.append(
                    .init(updateTime: lunchEndTime, meal: .dinner, targetDate: date)
                )
            }
            fallthrough
        case .dinner, .lunchDinner:
            if let nextDayFirstMeal = nextDayFirstMeal(today: date) {
                if let currentMealEndTime = oneDayOperatingHour(at: date)?.closeTime(of: .dinner, at: date) {
                    temp.append(
                        .init(updateTime: currentMealEndTime, meal: nextDayFirstMeal, targetDate: date.add(days: 1))
                    )
                } else if let currentMealEndTime =
                            oneDayOperatingHour(at: date)?.closeTime(of: .lunchDinner, at: date) {
                    temp.append(
                        .init(updateTime: currentMealEndTime, meal: nextDayFirstMeal, targetDate: date.add(days: 1))
                    )
                }
            }
        }
        return temp
    }
}
