//
//  SampleRestaurants.swift
//  SNUYum
//
//  Created by SEONG YEOL YI on 2021/04/02.
//

import Foundation

/// 프리뷰를 위한 샘플 데이터. 학생회관과 3식당의 정보만 제공.
let sampleRestaurants: [OneDayMenus] = [
    .init(id: .학생회관, contents: [
        .breakfast: [MenuNoticeWrapper(name: "아침 메뉴 1", cost: .exactly(cost: 1000))],
        .lunch: [
            MenuNoticeWrapper(name: "점심 메뉴 1", cost: .higherThan(cost: 2500)),
            MenuNoticeWrapper(name: "점심 메뉴 2", cost: .exactly(cost: 3000)),
            MenuNoticeWrapper(name: "점심 메뉴 3", cost: .unSpecified),
            MenuNoticeWrapper(name: "점심 메뉴 4", cost: .exactly(cost: 5000)),
            MenuNoticeWrapper(name: "점심 메뉴 5", cost: .exactly(cost: 4000)),
            MenuNoticeWrapper(notice: "첫번째 공지")!,
            MenuNoticeWrapper(notice: "두번째 공지")!
        ],
        .dinner: [MenuNoticeWrapper(name: "저녁 메뉴 1", cost: .unSpecified)]
    ]),
    .init(id: .삼, contents: [
        .breakfast: [MenuNoticeWrapper(name: "아침 메뉴 1", cost: .exactly(cost: 3000))],
        .lunch: [MenuNoticeWrapper(name: "점심 메뉴 1", cost: .unSpecified)],
        .dinner: [MenuNoticeWrapper(name: "저녁 메뉴 1", cost: .exactly(cost: 4000))]
    ])
]
