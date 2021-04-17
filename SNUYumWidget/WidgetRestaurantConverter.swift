//
//  WidgetRestaurantConverter.swift
//  SNUYum
//
//  Created by SEONG YEOL YI on 2021/04/07.
//

import Foundation

extension RestaurantID {
    init?(widgetRestaurantID: WidgetRestaurantID) {
        if let decoded = widgetRestaurantIDDecoder[widgetRestaurantID] {
            self = decoded
        } else {
            return nil
        }
    }
}

private let widgetRestaurantIDDecoder: [WidgetRestaurantID: RestaurantID] = [
    .art: .예술계,
    .dongwon: .동원관,
    .dorm: .기숙사,
    .dure: .두레미담,
    .gamgol: .감골,
    .gongdae: .공대간이,
    .jahayeon: .자하연,
    .lounge: .라운지오,
    .ourhome: .아워홈,
    .sodam: .소담마루,
    .studentCenter: .학생회관,
    .three: .삼,
    .threetwo: .삼백이,
    .threeone: .삼백일,
    .twotwo: .이백이십
]
