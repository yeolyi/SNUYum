//
//  MealButton.swift
//  SNUYum
//
//  Created by SEONG YEOL YI on 2021/04/02.
//

import SwiftUI

struct MealButton: View {
    
    @EnvironmentObject var restaurantUpdater: RestaurantUpdater
    
    var body: some View {
        Button(action: {
            withAnimation {
                restaurantUpdater.rotateMealViewMode()
            }
        }) {
            Text(restaurantUpdater.mealViewMode.description)
                .navigationText()
                .frame(width: 80, height: 30, alignment: .trailing)
        }
    }
}

struct MealViewModeButton_Previews: PreviewProvider {
    static var previews: some View {
        MealButton()
            .environmentObject(RestaurantUpdater())
    }
}
