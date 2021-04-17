//
//  OurhomeDecoder.swift
//  SNUYum
//
//  Created by SEONG YEOL YI on 2021/03/31.
//

import Foundation
import SwiftSoup
import Alamofire

/// 아워홈 홈페이지의 학식 정보를 가져와 가공합니다.
struct OurhomeDecoder {
    
    static let shared = Self()
    
    func download(
        at dateComponents: DateComponents,
        completion: @escaping ([DateComponents: OneDayMenus]) -> Void
    ) {
        getSource(at: dateComponents) { source in
            guard let source = source, let rawCafeList = divideRestaurants(in: source) else {
                completion([:])
                return
            }
            let ourhomeInfo = try? ourhome(at: dateComponents, rawCafeList: rawCafeList)
            // let nineOneInfo = try? nineone(at: dateComponents, rawCafeList: rawCafeList)
            let targetDateComponents = attachedDates(around: dateComponents)
            completion(
                targetDateComponents.reduce(into: [:]) { result, date in
                    result[date] = ourhomeInfo?[date] ?? .init(id: .아워홈, contents: [:])
                }
            )
        }
    }
    
    private func attachedDates(around dateComponents: DateComponents) -> [DateComponents] {
        let currentDate = Calendar.current.date(from: dateComponents)!
        let startDate = sameWeekFirstDate(at: currentDate)
        return Array(0...6).map {
            let date = startDate.add(days: $0)
            return DateComponents(year: date.year, month: date.month, day: date.day)
        }
    }
    
    private func divideRestaurants(in source: String) -> [Elements.Element]? {
        do {
            let parsed = try parse(source)
            return try parsed.select("tbody").select("tr").array()
        } catch {
            return nil
        }
    }
    
    private func sameWeekFirstDate(at date: Date) -> Date {
        var temp = date
        while temp.dayOfTheWeek != 1 {
            temp = temp.add(days: -1)
        }
        return temp
    }
    
    private func getSource(
        at dateComponents: DateComponents,
        completion: @escaping (String?) -> Void
    ) {
        let date = Calendar.current.date(from: dateComponents)!
        let sameWeekSunday = sameWeekFirstDate(at: date).dailyDateComponents
        let params: [String: Any] = [
            "action": "metapresso_dorm_food_week_list",
            "start_week_date": """
                \(sameWeekSunday.year!)-\(String(format: "%02d", sameWeekSunday.month!))-\
                \(String(format: "%02d", sameWeekSunday.day!))
                """,
            "target_blog": "39"
        ]
        AF.request("https://snudorm.snu.ac.kr/wp-admin/admin-ajax.php", method: .post,
                   parameters: params, encoding: URLEncoding.default
        ).responseString {
            let divided = $0.description.components(separatedBy: "|")
            guard divided.count == 2 else {
                completion(nil)
                return
            }
            completion($0.description.components(separatedBy: "|")[1])
        }
    }
    
    private func ourhome(
        at dateComponents: DateComponents,
        rawCafeList: [Elements.Element]
    ) throws -> [DateComponents: OneDayMenus]? {
        guard rawCafeList.count >= 8 else {
            return nil
        }
        let targetDateComponents = attachedDates(around: dateComponents)
        var storage: [DateComponents: [MenuNoticeWrapper?]] = targetDateComponents.reduce(into: [:], { result, next in
            result[next] = []
        })
        let subCafeOrder = ["가마", "인터쉐프", "가마", "인터쉐프", "해피존", "가마", "인터쉐프", "해피존"]
        let wasteDataNum = [3, 1, 2, 1, 1, 2, 1, 1]
        for rowNum in 0..<8 {
            let mealArray = try rawCafeList[rowNum].select("td").array()
            let infoStartIndex = wasteDataNum[rowNum]
            for columnNum in infoStartIndex..<infoStartIndex + 7 {
                let menuName = try mealArray[columnNum].select("li").text()
                let dayOfWeek = columnNum - infoStartIndex
                storage[targetDateComponents[dayOfWeek]]!.append(
                    menuNCost(rawMenuName: menuName, subCafeName: subCafeOrder[rowNum])
                )
            }
        }
        return storage.mapValues {
            OneDayMenus(
                id: .아워홈,
                contents: [
                    .breakfast: $0[...1].compactMap({$0}),
                    .lunch: $0[2...4].compactMap({$0}),
                    .dinner: $0[5...].compactMap({$0})
                ]
            )
        }
    }

    private func nineone(
        at dateComponents: DateComponents,
        rawCafeList: [Elements.Element]
    ) throws -> [DateComponents: OneDayMenus]? {
        guard rawCafeList.count >= 13 else {
            return nil
        }
        let targetDateComponents = attachedDates(around: dateComponents)
        var nineStorage: [DateComponents: [[MenuNoticeWrapper]]]
            = targetDateComponents.reduce(into: [:], { result, next in
            result[next] = [[MenuNoticeWrapper]].init(repeating: [], count: 3)
        })
        let nineWastedData = [2, 1, 1]
        for rowNum in 9..<12 {
            let indexByMeal = rowNum - 9
            let mealArray = try rawCafeList[rowNum].select("td").array()
            let rawMenus = try mealArray[nineWastedData[rowNum-9]...].map {
                try $0.select("li").text().components(separatedBy: " ")
            }
            for (dayOfWeekIndex, mealByDayOfWeek) in rawMenus.enumerated() {
                nineStorage[targetDateComponents[dayOfWeekIndex]]?[indexByMeal].append(
                    contentsOf: mealByDayOfWeek.compactMap {
                        menuNCost(rawMenuName: $0, subCafeName: nil)
                    }
                )
            }
        }
        return nineStorage.mapValues { menus in
            .init(id: .구백십구, contents: [
                .breakfast: menus[0],
                .lunch: menus[1],
                .dinner: menus[2]
            ])
        }
    }
    
    private func menuNCost(rawMenuName: String, subCafeName: String?) -> MenuNoticeWrapper? {
        guard rawMenuName != "" else {
            return nil
        }
        if let cost = menuTypeToCost[String(rawMenuName.first ?? Character(""))] {
            let menuNameTrimmed = String(rawMenuName.dropFirst())
            let menuNameWithSubCafeName = menuNameTrimmed + (subCafeName == nil ? "" : "(\(subCafeName!))")
            return .init(name: menuNameWithSubCafeName, cost: .exactly(cost: cost))
        } else {
            let menuNameWithSubCafeName = rawMenuName + (subCafeName == nil ? "" : "(\(subCafeName!))")
            return .init(name: menuNameWithSubCafeName, cost: .unSpecified)
        }
    }
    
    private let menuTypeToCost = [
        "A": 2000, "B": 2500, "C": 3000, "D": 3500, "E": 4000, "F": 4500, "G": 5000, "H": 5500
    ]
    
    private init() { }
}

extension Date {
    func add(days: Int) -> Date {
        var dayComponent = DateComponents()
        dayComponent.day = days
        let theCalendar = Calendar.current
        let nextDate = theCalendar.date(byAdding: dayComponent, to: self)!
        return nextDate
    }
}
