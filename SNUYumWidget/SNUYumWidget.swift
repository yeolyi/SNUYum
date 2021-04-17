//
//  SNUYumWidget.swift
//  SNUYumWidget
//
//  Created by SEONG YEOL YI on 2021/04/06.
//

import WidgetKit
import SwiftUI
import Intents

struct MenuWidget: View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    let entry: MenuScheduleEntry
    
    var body: some View {
        MenuNameList(entry: entry)
    }
}

@main
struct SNUYumWidget: Widget {
    let kind: String = "MenuWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: SelectRestaurantIntent.self, provider: Provider()) { entry in
            MenuWidget(entry: entry)
        }
        .configurationDisplayName("오늘의 메뉴")
        .description("선택한 식당의 메뉴를 시간에 따라 보여드립니다.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
