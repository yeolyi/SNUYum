//
//  Call.swift
//  SNUYum
//
//  Created by SEONG YEOL YI on 2021/04/06.
//

import SwiftUI

extension Restaurant {
    var phone: String? {
        phoneNumRaw[id]
    }
    var isCallAvailable: Bool {
        phoneNumRaw[id] != nil
    }
    func call() {
        if let phoneNum = phoneNumRaw[id] {
            let telephone = "tel://02-"
            let formattedString = telephone + phoneNum
            guard let url = URL(string: formattedString) else { return }
            UIApplication.shared.open(url)
        }
    }
}

private let phoneNumRaw: [RestaurantID: String] = [
    .학생회관: "880-5543",
    .자하연: "880-7888",
    .예술계: "876-1006",
    .두레미담: "880-9358",
    .동원관: "880-8697",
    .기숙사: "881-9072",
    .공대간이: "889-8956",
    .삼: "880-5545",
    .삼백이: "880-1939",
    .삼백일: "889-8955",
    .이백이십: "875-0240",
    .소담마루: "880-8698",
    .라운지오: "882-7005"
]
