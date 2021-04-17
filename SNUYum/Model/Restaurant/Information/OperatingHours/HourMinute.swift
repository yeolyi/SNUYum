//
//  HourMinute.swift
//  SNUYum
//
//  Created by SEONG YEOL YI on 2021/04/07.
//

import Foundation

/// 운영시간에서 한 시점(10시 15분 등)을 표현합니다.
struct HourMinute {
    
    /// - Important: "HH:MM"형태의 문자열이 아니면 초기화에 실패합니다.
    init?(_ raw: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        guard let testTime = formatter.date(from: raw) else {
            return nil
        }
        (hour, minute) = (testTime.hour, testTime.minute)
    }
    
    /// 입력받은 Date의 Date값에 구조체의 시간/분 값을 덧입혀 반환합니다.
    func matchingDatePoint(at date: Date) -> Date {
        Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: date)!
    }
    
    /// 시간차의 절댓값을 반환합니다.
    func distance(to date: Date) -> DateComponents {
        let calendar = Calendar.current
        let targetDate = matchingDatePoint(at: date)
        if date < targetDate {
            return calendar.dateComponents([.hour, .minute], from: date, to: targetDate)
        } else {
            return calendar.dateComponents([.hour, .minute], from: targetDate, to: date)
        }
    }
    
    private let hour: Int
    private let minute: Int
}

extension HourMinute: CustomStringConvertible {
    var description: String {
        "\(String(format: "%02d", hour)):\(String(format: "%02d", minute))"
    }
}

extension HourMinute: Equatable {
    
}
