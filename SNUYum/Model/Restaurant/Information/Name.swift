//
//  Name.swift
//  SNUYum
//
//  Created by SEONG YEOL YI on 2021/04/07.
//

import Foundation

extension Restaurant {
    var name: String {
        if let name = nameRaw[id] {
            return name
        } else {
            if case let .others(name) = id {
                print("저장되지 않은 식당 이름: \(name)")
                return name
            } else {
                assertionFailure()
                return ""
            }
        }
    }
}

private let nameRaw: [RestaurantID: String] = [
    .학생회관: "학생회관식당",
    .자하연: "자하연식당",
    .예술계: "예술계식당",
    .두레미담: "두레미담",
    .동원관: "동원관식당",
    .기숙사: "기숙사식당",
    .공대간이: "공대간이식당",
    .감골: "감골식당",
    .삼: "3식당",
    .삼백이: "302동식당",
    .삼백일: "301동식당",
    .이백이십: "220동식당",
    .소담마루: "소담마루",
    .라운지오: "라운지오",
    .아워홈: "아워홈",
    .구백십구: "919동식당"
]
