//
//  DayOfTheWeekType.swift
//  SNUYum
//
//  Created by SEONG YEOL YI on 2021/04/07.
//

import Foundation

/// 운영시간이 달라지는 평일, 토요일, 일요일에 대한 구분.
/// - Note: 운영시간 문자열 배열 해석을 위해 rawValue가 사용됩니다.
enum DayOfTheWeekType: Int, CaseIterable {
    case weekday, saturday, sunday
    init(date: Date) {
        switch date.dayOfTheWeek {
        case 1:
            self = .sunday
        case 7:
            self = .saturday
        default:
            self = .weekday
        }
    }
}
