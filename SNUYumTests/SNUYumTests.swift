//
//  SNUYumTests.swift
//  SNUYumTests
//
//  Created by SEONG YEOL YI on 2021/03/27.
//

import XCTest
@testable import SNUYum

class SNUYumTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testRestaurant() throws {
        var studentCenter = Restaurant(id: .학생회관)
        let testDate = DateComponents(year: 2021, month: 3, day: 29)
        studentCenter.setDate(to: testDate, decoder: HTMLDecoder.shared)
        XCTAssertEqual(studentCenter.name, "학생회관식당")
        XCTAssertEqual(studentCenter.getMenus(at: .lunch)?[0].name, "아보카도명란마요덮밥&육즙함박")
    }
    
    func testHTMLParser() throws {
        let htmlDecoder = HTMLDecoder.shared
        let targetDate = DateComponents(year: 2021, month: 3, day: 29)
        let studentCenter = htmlDecoder.restaurant(at: targetDate, of: .학생회관)!
        XCTAssertEqual(studentCenter.menus(at: .lunch)?[0].name, "아보카도명란마요덮밥&육즙함박")
        XCTAssertEqual(studentCenter.menus(at: .lunch)?[0].cost, Cost.exactly(cost: 5500))
        let gong = htmlDecoder.restaurant(at: targetDate, of: .공대간이)!
        XCTAssertEqual(gong.menus(at: .lunchDinner)?[0].name, "멘보샤")
        let ourhome = htmlDecoder.restaurant(at: targetDate, of: .아워홈)!
        XCTAssertEqual(ourhome.menus(at: .breakfast)?[0].name, "북어채해장국&소떡볶음 - 가마")
        XCTAssertEqual(ourhome.menus(at: .breakfast)?[0].cost, .exactly(cost: 3000))
    }

    func testFixedRestaurantInfo() throws {
        let dormFixedRestaurantInfo = Restaurant(id: .기숙사)
        XCTAssertEqual(dormFixedRestaurantInfo.name, "기숙사식당")
        XCTAssertEqual(dormFixedRestaurantInfo.location?.latitude, 37.463120)
        XCTAssertEqual(dormFixedRestaurantInfo.location?.longitude, 126.958669)
        XCTAssertEqual(dormFixedRestaurantInfo.phone, "881-9072")
        
        let testTime = makeDate(using: "2021/03/28 15:00")
        XCTAssertEqual(dormFixedRestaurantInfo.operatingHours?.status(at: testTime),
                       OperatingHourStatus.waiting(meal: .dinner, remaining: DateComponents(hour: 2, minute: 30)))
    }
 
    func testOperatingHours() throws {
        let rawData: [[String?]?] = [
            ["08:00-09:30", "11:00-15:00", "17:00-19:00"],
            [nil, "11:30-14:00", "17:00-19:00"],
            [nil, "11:00-17:00", "11:00-17:00"]
        ]
        let operatingHours = OperatingHours(rawData)
        
        func isEqual(dateFormat: String, description: String?, status: OperatingHourStatus) {
            let date = makeDate(using: dateFormat)
            XCTAssertEqual(description, operatingHours.description(at: date))
            XCTAssertEqual(operatingHours.status(at: date), status)
        }
        
        isEqual(dateFormat: "2021/03/22 04:00", description: nil, status: .close)
        isEqual(dateFormat: "2021/03/22 05:10", description: "08:00 ~ 09:30",
                status: .waiting(meal: .breakfast, remaining: DateComponents(hour: 2, minute: 50)))
        isEqual(dateFormat: "2021/03/22 08:45", description: "08:00 ~ 09:30",
                status: .open(meal: .breakfast, remaining: DateComponents(hour: 0, minute: 45)))
        isEqual(dateFormat: "2021/03/22 10:06", description: "11:00 ~ 15:00",
                status: .waiting(meal: .lunch, remaining: DateComponents(hour: 0, minute: 54)))
        
        isEqual(dateFormat: "2021/03/27 12:17", description: "11:30 ~ 14:00",
                status: .open(meal: .lunch, remaining: DateComponents(hour: 1, minute: 43)))
        
        isEqual(dateFormat: "2021/03/28 08:45", description: "11:00 ~ 17:00",
                status: .waiting(meal: .lunchDinner, remaining: DateComponents(hour: 2, minute: 15)))
        isEqual(dateFormat: "2021/03/28 15:15", description: "11:00 ~ 17:00",
                status: .open(meal: .lunchDinner, remaining: DateComponents(hour: 1, minute: 45)))
    }
    
    func makeDate(using formatStr: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter.date(from: formatStr)!
    }
}
