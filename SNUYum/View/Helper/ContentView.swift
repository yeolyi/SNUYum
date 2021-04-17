//
//  ContentView.swift
//  SNUYum
//
//  Created by SEONG YEOL YI on 2021/03/27.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        TabView {
            RestaurantTab()
                .tabItem {
                    Image(systemName: "rectangle.grid.1x2")
                    Text("식당")
                }
            SettingTab()
                .tabItem {
                    if #available(iOS 14, *) {
                        Image(systemName: "gearshape")
                    } else {
                        Image(systemName: "gear")
                    }
                    Text("설정")
                }
        }
        .accentColor(.brand)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(RestaurantUpdater())
    }
}
