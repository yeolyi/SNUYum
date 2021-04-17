//
//  MenuNameList.swift
//  SNUYum
//
//  Created by SEONG YEOL YI on 2021/04/07.
//

import SwiftUI
import WidgetKit

struct MenuNameList: View {
    @Environment(\.widgetFamily) var widgetFamily
    let entry: MenuScheduleEntry
    
    init(entry: MenuScheduleEntry) {
        self.entry = entry
    }
    
    var operatingHourInfo: String? {
        if let meal = entry.meal {
            return entry.restaurant?.operatingHours?.description(at: entry.date, meal: meal)
        } else {
            return nil
        }
    }
    
    var dateInfo: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko-kr")
        let dayOfTheWeekStr = dateFormatter.weekdaySymbols[entry.menuDate.dayOfTheWeek - 1]
        return """
            \(dayOfTheWeekStr) \(entry.meal?.description ?? "") \
            \(widgetFamily == .systemMedium ? (operatingHourInfo ?? "") : "")
            """
    }

    var additionalMenuInfo: String? {
        guard let menu = entry.menuDownloaded, menu.count > 3 else {
            return nil
        }
        return "+ \(menu.count - 3)개 메뉴"
    }
    
    var body: some View {
        if entry.restaurant == nil {
            Text("위젯을 길게 눌러\n식당을 선택하세요😋")
                .widgetBody()
                .padding()
        } else {
            VStack(spacing: 8) {
                VStack {
                    Text(dateInfo)
                        .widgetSubtitle()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(entry.restaurant?.name ?? "")
                        .widgetTitle()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity)
                .padding([.horizontal, .top], 10)
                .padding(.bottom, 5)
                .background(Color.brand)
                VStack(spacing: 3) {
                    ForEach(entry.menuDownloaded?.prefix(3) ?? []) { menu in
                        HStack {
                            Text(menu.name)
                                .widgetBody()
                                .lineLimit(1)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Spacer()
                            if widgetFamily == .systemMedium {
                                Text(menu.cost.detailDescription)
                                    .widgetBody()
                                    .lineLimit(1)
                            }
                        }
                    }
                    if entry.menuDownloaded?.isEmpty != false {
                        Text("메뉴가 없어요")
                            .widgetBody()
                            .padding()
                    }
                }
                .padding(.horizontal, 10)
                if let additionalMenuInfo = additionalMenuInfo {
                    Text(additionalMenuInfo)
                        .widgetCaption()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 10)
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
    }
}

struct SNUYumWidget_Previews: PreviewProvider {
    
    static let sampleEntry = MenuScheduleEntry(
        restaurant: Restaurant.getSample(), meal: .lunch, menus: Restaurant.getSample().menus(at: .lunch)
    )
    static var previews: some View {
        MenuNameList(entry: sampleEntry)
        .previewContext(WidgetPreviewContext(family: .systemSmall))
        MenuNameList(entry: sampleEntry)
        .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
