//
//  Meal.swift
//  SNUYum
//
//  Created by SEONG YEOL YI on 2021/03/27.
//

import Foundation

/// 시간에 따른 끼니의 종류를 표현합니다.
enum Meal: CaseIterable {
    case breakfast, lunch, dinner, lunchDinner
    
    /// lunchDinner값과 다른 Meal값을 변환합니다
    /// - Parameters:
    ///   - meal: 기준 Meal값
    ///   - target: Meal값에 대응하는 데이터가 존재하는지 유무
    ///   - action: lunchDinnerState값에 따른 행동
    static func lunchDinnerConvertable<T>(
        _ meal: Meal, target: (Meal) -> Bool, action: (LunchDinnerState) -> T?
    ) -> T? {
        if meal == .lunchDinner && target(meal) == false {
            return action(.noLunchDinner)
        } else if (meal == .lunch || meal == .dinner) && target(meal) == false {
            return action(.onlyLunchDinner)
        } else {
            return action(.default)
        }
    }
    
    /// lunchDinner값과 다른 Meal값의 변환 가능성을 표현합니다.
    enum LunchDinnerState {
        case onlyLunchDinner, noLunchDinner, `default`
    }
}

extension Meal: Comparable {
    
}

extension Meal: Identifiable {
    var id: String {
        description
    }
}

extension Meal: Codable {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        if let decoded = Self.allCases.first(where: {$0.description == rawValue}) {
            self = decoded
        } else {
            assertionFailure()
            self = .lunch
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(description)
    }
    
}

extension Meal: CustomStringConvertible {
    var description: String {
        switch self {
        case .breakfast:
            return "아침"
        case .lunch:
            return "점심"
        case .dinner:
            return "저녁"
        case .lunchDinner:
            return "점심저녁"
        }
    }
}
