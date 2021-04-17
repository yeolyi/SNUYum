//
//  DailyDateComponents.swift
//  SNUYum
//
//  Created by SEONG YEOL YI on 2021/04/07.
//

import Foundation

extension Date {
    var dailyDateComponents: DateComponents {
        Calendar.current.dateComponents([.year, .month, .day], from: self)
    }
}

extension Date {
    var year: Int {
        Calendar.current.dateComponents([.year], from: self).year!
    }
    var month: Int {
        Calendar.current.dateComponents([.month], from: self).month!
    }
    var day: Int {
        Calendar.current.dateComponents([.day], from: self).day!
    }
    var hour: Int {
        Calendar.current.dateComponents([.hour], from: self).hour!
    }
    var minute: Int {
        Calendar.current.dateComponents([.minute], from: self).minute!
    }
    var dayOfTheWeek: Int {
        Calendar.current.dateComponents([.weekday], from: self).weekday!
    }
}
