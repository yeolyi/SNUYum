//
//  RelativeDatePosition.swift
//  SNUYum
//
//  Created by SEONG YEOL YI on 2021/04/07.
//

import Foundation

/// 특정 시각이 영업 시간 기준 어디에 위치하는지 분류합니다.
enum RelativeDatePosition {
    case before, contains, after
}
