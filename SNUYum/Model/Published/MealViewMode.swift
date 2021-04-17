//
//  MealViewMode.swift
//  SNUYum
//
//  Created by SEONG YEOL YI on 2021/04/01.
//

import Foundation

/// 사용자에게 보여줄 끼니에 대한 설정을 나타냅니다. 아침 고정/점심 고정/저녁 고정/자동.
enum MealViewMode: CaseIterable {
    
    case breakfast, lunch, dinner, auto
    
    var rotatingNext: Self {
        let all = Self.allCases
        let idx = all.firstIndex(of: self)!
        let next = all.index(after: idx)
        return all[next == all.endIndex ? all.startIndex : next]
    }
}

extension MealViewMode: CustomStringConvertible {
    var description: String {
        switch self {
        case .auto:
            return "자동"
        case .breakfast:
            return "아침 고정"
        case .lunch:
            return "점심 고정"
        case .dinner:
            return "저녁 고정"
        }
    }
}

extension MealViewMode: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        if let converted = MealViewMode.allCases.first(where: {$0.description == rawValue}) {
            self = converted
        } else {
            switch rawValue {
            case "아침":
                self = .breakfast
            case "점심":
                self = .lunch
            case "저녁":
                self = .dinner
            default:
                self = .auto
            }
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(description)
    }
}
