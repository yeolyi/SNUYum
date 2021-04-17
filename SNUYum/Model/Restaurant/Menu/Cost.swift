//
//  Cost.swift
//  SNUYum
//
//  Created by SEONG YEOL YI on 2021/03/29.
//

import Foundation

/// 식단 메뉴의 가격을 종류에 따라 표현합니다.
enum Cost: Equatable {
    case higherThan(cost: Int)
    case exactly(cost: Int)
    case unSpecified
    
    var detailDescription: String {
        switch self {
        case .higherThan(let cost):
            return "\(cost)원 이상"
        case .exactly(let cost):
            return "\(cost)원"
        case .unSpecified:
            return "-"
        }
    }
}

extension Cost: CustomStringConvertible {
    var description: String {
        switch self {
        case .higherThan(let cost):
            let costCut = String(format: "%.1f", Double(cost)/1000.0)
            return "\(costCut)+"
        case .exactly(let cost):
            let costCut = String(format: "%.1f", Double(cost)/1000.0)
            return "\(costCut)"
        case .unSpecified:
            return "-"
        }
    }
}

extension Cost: Codable {
    enum Key: CodingKey {
        case rawValue
        case associatedValue
    }
    
    enum CodingError: Error {
        case unknownValue
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        let rawValue = try container.decode(Int.self, forKey: .rawValue)
        switch rawValue {
        case 0:
            let cost = try container.decode(Int.self, forKey: .associatedValue)
            self = .exactly(cost: cost)
        case 1:
            let cost = try container.decode(Int.self, forKey: .associatedValue)
            self = .higherThan(cost: cost)
        case 2:
            self = .unSpecified
        default:
            throw CodingError.unknownValue
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        switch self {
        case .exactly(let cost):
            try container.encode(0, forKey: .rawValue)
            try container.encode(cost, forKey: .associatedValue)
        case .higherThan(let cost):
            try container.encode(1, forKey: .rawValue)
            try container.encode(cost, forKey: .associatedValue)
        case .unSpecified:
            try container.encode(2, forKey: .rawValue)
        }
    }
}
