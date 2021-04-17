//
//  SuggestionChooser.swift
//  SNUYum
//
//  Created by SEONG YEOL YI on 2021/04/05.
//

import SwiftUI

struct SuggestionChooser: View {
    
    @EnvironmentObject var restaurantUpdater: RestaurantUpdater
    
    var body: some View {
        List {
            ForEach(RestaurantID.allCases) { id in
                HStack {
                    Text(Restaurant(id: id).name)
                    Spacer()
                    if restaurantUpdater.timelyMealStandard == id {
                        Image(systemName: "checkmark")
                            .foregroundColor(.secondary)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    restaurantUpdater.timelyMealStandard = id
                }
            }
        }
        .navigationBarTitle(Text("시간별 추천 기준"), displayMode: .inline)
    }
}

struct SuggestionChooser_Previews: PreviewProvider {
    static var previews: some View {
        SuggestionChooser()
            .environmentObject(RestaurantUpdater())
    }
}
