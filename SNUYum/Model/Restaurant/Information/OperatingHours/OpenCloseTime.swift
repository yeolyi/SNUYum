//
//  OpenCloseTime.swift
//  SNUYum
//
//  Created by SEONG YEOL YI on 2021/04/07.
//

import Foundation

struct OpenCloseTime {
    
    let open: HourMinute
    let close: HourMinute
    
    /// - Important: "HH:MM-HH:MM"형태의 문자열이 아니면 초기화에 실패합니다.
    init?(_ raw: String) {
        let openCloseSplitted = raw.components(separatedBy: "-")
        guard openCloseSplitted.count == 2,
              let open = HourMinute(openCloseSplitted[0]),
              let close = HourMinute(openCloseSplitted[1]) else {
            return nil
        }
        self.open = open
        self.close = close
    }
    
    /// 특정 시각이 구조체가 표현하는 시간 범위 대비 어디에 위치하는지 반환합니다.
    func position(of date: Date) -> RelativeDatePosition {
        if date < open.matchingDatePoint(at: date) {
            return .before
        } else if date > close.matchingDatePoint(at: date) {
            return .after
        } else {
            return .contains
        }
    }
    
    /// 시간 범위와 특정 시간의 시간차를 구합니다.
    /// - Returns: 시간 범위 이후에서는 nil을 반환합니다.
    func remainingTime(from date: Date) -> DateComponents? {
        switch position(of: date) {
        case .after:
            return nil
        case .before:
            return open.distance(to: date)
        case .contains:
            return close.distance(to: date)
        }
    }
}

extension OpenCloseTime: CustomStringConvertible {
    var description: String {
        "\(open) ~ \(close)"
    }
}

extension OpenCloseTime: Equatable {
    
}
