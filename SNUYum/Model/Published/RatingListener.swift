//
//  RatingListener.swift
//  SNUYum
//
//  Created by SEONG YEOL YI on 2021/04/13.
//

import SwiftUI
import Firebase

enum RatingErrors: Error {
    case notLogined, oneDayLimit
}

/// 한 Restaurant 객체의 별점 및 체크인 여부를 관리합니다.
class RatingListener: ObservableObject {
    
    @Published private var checkinMembers: [String: [String]] = [:]
    @Published private(set) var ratings: [String: [String: Int]] = [:]
    @Published var authManager: AuthManager
    @Published var isLoading = true
    
    private var currentDate: DateComponents = Date().dailyDateComponents
    private(set) var todayCheckinNum = 0
    
    let restaurantName: String
    let maximumCheckinCount = 4
    
    var totalCheckin: Int {
        checkinMembers.reduce(into: Set<String>()) { result, next in
            for member in next.value {
                result.insert(member)
            }
        }.count
    }
    
    private var checkinNum: [String: Int] {
        checkinMembers.mapValues(\.count)
    }
    
    func totalMenuCheckin(in menuName: String) -> Int {
        checkinNum[menuName.badCharInFirebaseRemoved] ?? 0
    }
    
    func update() {
        setDate(to: currentDate)
    }
    
    func isCheckined(in menuName: String) -> Bool {
        guard let id = authManager.userID else {
            return false
        }
        if let contained = checkinMembers[menuName.badCharInFirebaseRemoved]?.contains(id) {
            return contained
        } else {
            return false
        }
    }
    
    func toggleCheckin(to menuName: String) throws {
        guard authManager.userID != nil else {
            throw RatingErrors.notLogined
        }
        if isCheckined(in: menuName) {
            cancelCheckin(to: menuName)
        } else {
            guard todayCheckinNum < maximumCheckinCount else {
                throw RatingErrors.oneDayLimit
            }
            try checkin(to: menuName)
        }
    }
    
    private func cancelCheckin(to menuName: String) {
        guard let id = authManager.userID else {
            return
        }
        let menuNameWithoutBadString = menuName.badCharInFirebaseRemoved
        let ref = Database.database().reference().child("stars")
            .child(restaurantName).child(currentDate.databaseStr).child(menuNameWithoutBadString).child("checkin")
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if let value = snapshot.value as? [String], value.contains(id) {
                var newValue = value
                newValue.removeAll(where: { $0 == id })
                ref.setValue(newValue)
                self.todayCheckinNum = max(0, self.todayCheckinNum - 1)
                self.setCheckinCount(to: self.todayCheckinNum)
            }
        }
    }
    
    private func checkin(to menuName: String) throws {
        guard let id = authManager.userID else {
            throw RatingErrors.notLogined
        }
        maximumCheckinCountExceeded { isExceeded in
            guard isExceeded == false else {
                return
            }
            let menuNameWithoutBadString = menuName.badCharInFirebaseRemoved
            print(menuNameWithoutBadString)
            let ref = Database.database().reference().child("stars")
                .child(self.restaurantName).child(self.currentDate.databaseStr)
                .child(menuNameWithoutBadString).child("checkin")
            ref.observeSingleEvent(of: .value) { (snapshot) in
                if let value = snapshot.value as? [String] {
                    if !value.contains(id) {
                        ref.setValue(value + [id])
                        self.todayCheckinNum += 1
                        self.setCheckinCount(to: self.todayCheckinNum)
                    }
                } else {
                    ref.setValue([id])
                    self.todayCheckinNum += 1
                    self.setCheckinCount(to: self.todayCheckinNum)
                }
            }
        }
    }
    
    private func maximumCheckinCountExceeded(completion: @escaping (Bool) -> Void) {
        guard let id = authManager.userID else {
            completion(false)
            return
        }
        let ref = Database.database().reference().child("users")
            .child(id).child(currentDate.databaseStr).child("ratingNum")
        ref.observeSingleEvent(of: .value) { snapshot in
            if let value = snapshot.value as? Int, value >= self.maximumCheckinCount {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    private func setCheckinCount(to count: Int) {
        guard let id = authManager.userID else {
            return
        }
        let ref = Database.database().reference().child("users")
            .child(id).child(currentDate.databaseStr).child("ratingNum")
        ref.setValue(todayCheckinNum)
    }
    
    private func getCheckinCount(completion: @escaping () -> Void) {
        guard let id = authManager.userID else {
            completion()
            return
        }
        let ref = Database.database().reference().child("users")
            .child(id).child(currentDate.databaseStr).child("ratingNum")
        ref.observe(.value) { snapshot in
            if let count = snapshot.value as? Int {
                self.todayCheckinNum = count
            }
            completion()
        }
    }
    
    func setDate(to dateComponents: DateComponents) {
        currentDate = dateComponents
        let ref = Database.database().reference().child("stars")
            .child(restaurantName).child(currentDate.databaseStr)
        ref.observe(.value) { snapshot in
            if let datas = snapshot.children.allObjects as? [DataSnapshot] {
                let results: [String: [String]] = datas.reduce(into: [:]) { result, next in
                    let menuName = next.key
                    result[menuName] = next.childSnapshot(forPath: "checkin").value as? [String]
                }
                self.checkinMembers = results
            }
            self.isLoading = false
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(3)) {
            self.isLoading = false
        }
    }
    
    init(authManager: AuthManager, restaurantName: String) {
        self.authManager = authManager
        self.restaurantName = restaurantName
        
        getCheckinCount {
            self.setDate(to: Date().dailyDateComponents)
        }
    }
}

extension DateComponents {
    var databaseStr: String {
        let monthTwoDigit = String(format: "%02d", month ?? 0)
        let dayTwoDigiit = String(format: "%02d", day ?? 0)
        return "\(year ?? 0)-\(monthTwoDigit)-\(dayTwoDigiit)"
    }
}

extension String {
    var badCharInFirebaseRemoved: String {
        self
            .replacingOccurrences(of: "#", with: "")
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: "[", with: "")
            .replacingOccurrences(of: "]", with: "")
            .replacingOccurrences(of: "/", with: "")
    }
}
