//
//  HTMLParser.swift
//  SNUYum
//
//  Created by SEONG YEOL YI on 2021/03/29.
//

import Foundation
import SwiftSoup
import Network

/// 생협 및 아워홈 홈페이지에서 정보를 가져와 가공합니다.
class HTMLDecoder {
    
    static let shared = HTMLDecoder()
    
    func willDownload(at dateComponents: DateComponents) -> Bool {
        (storage[dateComponents]?.count ?? 0) <= 1
    }
    
    /// 해당 일자에 정보가 존재하는 모든 식당의 ID를 반환합니다.
    func allRestaurantIDs(at dateComponents: DateComponents, completion: @escaping ([RestaurantID]) -> Void) {
        self.downloadIfEmpty(at: dateComponents) { downloaded in
            completion(downloaded?.map(\.id) ?? [])
        }
    }
    
    /// 특정 식당의 특정 일자의 메뉴와 공지를 불러옵니다.
    /// - Returns: 입력받은 시기에 메뉴나 공지가 없으면 nil을 반환합니다.
    func downloadedRestaurantMenus(
        at dateComponents: DateComponents, of restaurantID: RestaurantID, completion: @escaping (OneDayMenus?) -> Void
    ) {
        self.downloadIfEmpty(at: dateComponents) { downloaded in
            completion(downloaded?.first(where: {$0.id == restaurantID}))
        }
    }
    
    func clear() {
        storage = [:]
    }
    
    private func downloadIfEmpty(
        at dateComponents: DateComponents,
        completion: @escaping ([OneDayMenus]?) -> Void
    ) {
        if (storage[dateComponents]?.count ?? 0) <= 1 {
            download(at: dateComponents) { downloaded in
                completion(downloaded)
                return
            }
        } else {
            completion(storage[dateComponents])
        }
    }
    
    private func download(
        at dateComponents: DateComponents,
        completion: @escaping ([OneDayMenus]?) -> Void
    ) {
        print("학식 정보 다운로드 중... \(dateComponents)")
        // 프리뷰에서는 일관된 메뉴값 반환
        guard !isPreview else {
            storage[dateComponents] = sampleRestaurants
            completion(sampleRestaurants)
            return
        }
        SNUCODecoder.shared.menus(at: dateComponents) { snuco in
            print("SNUCO 완료")
            self.storage[dateComponents] = snuco
            OurhomeDecoder.shared.download(at: dateComponents) { ourhome in
                print("Ourhome 완료")
                for (date, ourhomeData) in ourhome {
                    if self.storage[date] == nil {
                        self.storage[date] = [ourhomeData]
                    } else {
                        self.storage[date]?.removeAll(where: { $0.id == .아워홈 })
                        self.storage[date]!.append(ourhomeData)
                    }
                }
                completion(self.storage[dateComponents])
            }
        }
        
    }
    
    @AutoSave("htmlStorage", defaultValue: [:])
    private var storage: [DateComponents: [OneDayMenus]]
    
    @AutoSave("ourhomeFixedFirstRun", defaultValue: true)
    private var ourhomeFixedFirstRun: Bool
    
    private init() {
        if isPreview { storage = [:] }
        if ourhomeFixedFirstRun {
            storage = [:]
            ourhomeFixedFirstRun = false
        }
    }
}
