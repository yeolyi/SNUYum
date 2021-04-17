//
//  RestaurantID.swift
//  SNUYum
//
//  Created by SEONG YEOL YI on 2021/04/07.
//

import Foundation

enum RestaurantID: Hashable, CaseIterable {
    case 아워홈, 구백십구, 학생회관, 자하연, 예술계, 소담마루, 라운지오, 두레미담, 동원관, 기숙사, 공대간이, 감골, 삼, 삼백이, 삼백일, 이백이십
    case others(name: String)
    init(_ name: String) {
        if let decoded = nameDecode[name] {
            self = decoded
        } else {
            self = .others(name: name)
        }
    }
    static var allCases: [Self] {
        return [.학생회관, .자하연, .예술계, .소담마루, .라운지오, .두레미담,
                .동원관, .기숙사, .공대간이, .감골, .삼, .삼백이, .삼백일, .이백이십, .아워홈, .구백십구]
    }
    
}

extension RestaurantID: Comparable {
    
}

private let nameDecode: [String: RestaurantID] = [
    "학생회관식당": .학생회관,
    "자하연식당": .자하연,
    "예술계식당": .예술계,
    "두레미담": .두레미담,
    "동원관식당": .동원관,
    "기숙사식당": .기숙사,
    "공대간이식당": .공대간이,
    "감골식당": .감골,
    "3식당": .삼,
    "302동식당": .삼백이,
    "301동식당": .삼백일,
    "220동식당": .이백이십,
    "소담마루": .소담마루,
    "라운지오": .라운지오,
    "아워홈": .아워홈,
    "919동식당": .구백십구
]

extension RestaurantID: Identifiable {
    var id: String {
        Restaurant(id: self).name
    }
}

extension RestaurantID: Codable {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = .init(rawValue)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let rawValue = Restaurant(id: self).name
        try container.encode(rawValue)
    }
}
