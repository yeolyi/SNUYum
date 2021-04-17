//
//  DetailMap.swift
//  SNUYum
//
//  Created by SEONG YEOL YI on 2021/04/05.
//

import SwiftUI

struct DetailMap: View {
    
    let restaurant: Restaurant
    
    var body: some View {
        NavigationView {
            ZStack {
                NaverMap(restaurant: restaurant)
                    .edgesIgnoringSafeArea(.all)
            }
            .navigationBarTitle(Text(restaurant.locationDescription ?? ""), displayMode: .inline)
        }
    }
}

struct DetailMap_Previews: PreviewProvider {
    static var previews: some View {
        DetailMap(restaurant: Restaurant(id: .학생회관))
    }
}
