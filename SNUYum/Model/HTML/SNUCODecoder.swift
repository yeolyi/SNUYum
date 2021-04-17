//
//  SNUCODecoder.swift
//  SNUYum
//
//  Created by SEONG YEOL YI on 2021/03/31.
//

import Foundation
import SwiftSoup

enum DecoderError: Error {
    case blah
}

/// 생협 홈페이지의 학식 정보를 가져와 가공합니다.
///
/// - Note: 내부적으로 MenuNoticeWrapper를 사용하고 OneDayMenus로 변환하여 반환합니다.
struct SNUCODecoder {
    
    static let shared = Self()
    
    func menus(at dateComponents: DateComponents, completion: @escaping ([OneDayMenus]?) -> Void) {
        DispatchQueue.global().async {
            let url = makeURL(from: dateComponents)
            do {
                do {
                    let htmlString = try String(contentsOf: url)
                    let document = try SwiftSoup.parse(htmlString)
                    let rawCafeList = try splitCafes(in: document)
                    completion(
                        rawCafeList.compactMap {
                            do {
                                return try buildCafe(from: $0)
                            } catch {
                                return nil
                            }
                        }
                    )
                } catch {
                    completion(nil)
                }
            }
            
        }
    }
    
    /// 파싱된 정보를 식당 단위로 나눕니다.
    private func splitCafes(in document: Document) throws -> [Element] {
        try document.select("div.view-content").select("tbody").select("tr").array()
    }
    
    /// 개별 식당 정보를 가공합니다.
    private func buildCafe(from element: Element) throws -> OneDayMenus {
        let cafeElements = try splitCafeComponents(in: element)
        let restaurantID = try splitRestaurantID(from: cafeElements)
        let restaurantContents = try splitRestaurantContents(from: cafeElements)
        return .init(id: restaurantID, contents: restaurantContents)
    }
    
    /// 개별 식당을 요소로 분리합니다.
    private func splitCafeComponents(in element: Element) throws -> [Elements.Element] {
        try element.select("td").array()
    }
    
    /// 식당 요소에서 ID값을 얻어냅니다.
    private func splitRestaurantID(from cafeElements: [Element]) throws -> RestaurantID {
        let str = try cafeElements[0].text()
        let tempArr = str.components(separatedBy: ["("])
        guard tempArr.count == 2 else {
            throw DecoderError.blah
        }
        return RestaurantID(tempArr[0])
    }
    
    /// 식당 요소에서 끼니별 메뉴/공지값을 얻어냅니다.
    private func splitRestaurantContents(from rawCafe: [Element]) throws
    -> [Meal: [MenuNoticeWrapper]] {
        let tempBreakfastMenus = try rawCafe[1].select("p").array()
        let tempLunchMenus = try rawCafe[2].select("p").array()
        let tempDinnerMenus = try rawCafe[3].select("p").array()
        let breakfastMenus = try packMenus(tempBreakfastMenus)
        let lunchMenus = try packMenus(tempLunchMenus)
        let dinnerMenus = try packMenus(tempDinnerMenus)
        if lunchMenus == dinnerMenus {
            return [.breakfast: breakfastMenus, .lunchDinner: lunchMenus].filter { _, value in
                !value.isEmpty
            }
        } else {
            return [.breakfast: breakfastMenus, .lunch: lunchMenus, .dinner: dinnerMenus].filter { _, value in
                !value.isEmpty
            }
        }
    }
    
    /// 각 끼니에서 개별 메뉴/공지를 분리합니다.
    private func packMenus(_ elements: [Element]) throws -> [MenuNoticeWrapper] {
        try elements.reduce([], { result, next in
            var temp = try next.html()
            temp = temp.replacingOccurrences(of: "<br>", with: "쀓")
            temp = try parse(temp).text()
            let menuList = temp.split(separator: "쀓").map(String.init).map {$0.whiteSpaceTrimmed}
            return result + menuList.compactMap(classifyMenu)
        })
    }
    
    /// 메뉴/공지를 가공합니다.
    private func classifyMenu(next: String) -> MenuNoticeWrapper? {
        guard !next.isEmpty else {
            return nil
        }
        let firstCheck = menuFirstCheck(next)
        if firstCheck.isException {
            if firstCheck.save {
                return MenuNoticeWrapper(notice: next)
            } else {
                return nil
            }
        }
        return findCost(in: next)
    }
    
    /// 메뉴에서 가격을 분리합니다.
    private func findCost(in str: String) -> MenuNoticeWrapper? {
        for index in str.indices {
            guard index != str.index(before: str.endIndex) else {
                return .init(name: str, cost: .unSpecified)
            }
            let currentStr = String(str[index])
            let nextStr = String(str[str.index(after: index)])
            if Int(currentStr) != nil && (nextStr == "," || Int(nextStr) != nil ) {
                let name = String(str[..<index]).whiteSpaceTrimmed
                let cost = String(str[index...]).decimal
                if let cost = cost {
                    if String(str[index...]).contains("~") {
                        return .init(name: name, cost: .higherThan(cost: cost))
                    } else {
                        return .init(name: name, cost: .exactly(cost: cost))
                    }
                } else {
                    return .init(name: name, cost: .unSpecified)
                }
            }
        }
        return nil
    }
    
    /// 메뉴와 공지를 구별합니다.
    private func menuFirstCheck(_ menuNCost: String) -> (isException: Bool, save: Bool) {
        if menuNCost.isEmpty || menuNCost.contains("운영") {
            return (true, false)
        } else if menuNCost.contains("혼잡") || menuNCost.contains("코로나") || menuNCost.contains("주문은")
        || menuNCost.contains("브레이크") {
            return (true, true)
        } else {
            return (false, false)
        }
    }
    
    /// 날짜별 URL을 만듭니다.
    private func makeURL(from dateComponents: DateComponents) -> URL {
        let targetURLString = """
        https://snuco.snu.ac.kr/ko/\
        foodmenu?field_menu_date_value_1%5Bvalue%5D%5Bdate%5D=&field_menu_date_value%5Bvalue%5D%5Bdate%5D=\
        \(dateComponents.month!)%2F\(dateComponents.day!)%2F\(dateComponents.year!)
        """
        if let targetURL = URL(string: targetURLString) {
            return targetURL
        } else {
            assertionFailure("String to URL failed - \(targetURLString)")
            return URL(string: "https://snuco.snu.ac.kr/ko/foodmenu")!
        }
    }
}

extension String {
    var whiteSpaceTrimmed: String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    var decimal: Int? {
        Int(self.components(separatedBy: CharacterSet.decimalDigits.inverted).joined())
    }
}
