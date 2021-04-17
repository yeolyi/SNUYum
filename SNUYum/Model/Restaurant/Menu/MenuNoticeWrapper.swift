//
//  DownloadedRestaurantContent.swift
//  SNUYum
//
//  Created by SEONG YEOL YI on 2021/03/31.
//

import Foundation

/// 식단을 html에서 불러오는 과정에서 메뉴와 공지를 저장 및 반환합니다.
struct MenuNoticeWrapper: Equatable, CustomStringConvertible {
    init(name: String, cost: Cost) {
        type = .menu
        self._name = name
        self._cost = cost
        _notice = nil
    }
    init?(notice: String) {
        guard notice != "" else {
            return nil
        }
        type = .notice
        self._notice = notice
        _name = nil
        _cost = nil
    }
    var menu: (name: String, cost: Cost)? {
        guard type == .menu, _name != nil, _cost != nil else {
            return nil
        }
        return (_name!, _cost!)
    }
    var notice: String? {
        guard type == .notice, _notice != nil else {
            return nil
        }
        return _notice!
    }
    var description: String {
        switch type {
        case .menu:
            return "\(_name!): \(_cost!)"
        case .notice:
            return _notice!
        }
    }
    
    private let type: ContentType
    private let _name: String?
    private let _cost: Cost?
    private let _notice: String?
    private enum ContentType: Int, Codable {
        case menu, notice
    }
}

extension MenuNoticeWrapper: Codable {
    
}
