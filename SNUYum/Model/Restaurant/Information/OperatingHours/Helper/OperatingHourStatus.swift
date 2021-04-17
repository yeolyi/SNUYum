//
//  OperatingHourStatus.swift
//  SNUYum
//
//  Created by SEONG YEOL YI on 2021/04/07.
//

import Foundation

/// 특정 시각에 식당이 어떤 상태인지 구분합니다.
enum OperatingHourStatus: Equatable {
    /// 각 끼니별 영업 시작을 기다리고 있는 상태
    case waiting(meal: Meal, remaining: DateComponents)
    /// 끼니별 영업을 시작한 상태
    case open(meal: Meal, remaining: DateComponents)
    /// 당일 영업을 종료한 상태
    case close
    /// 당일 오픈을 기다리는 상태
    case waitingOpen
}
