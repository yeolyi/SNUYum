//
//  ReorderFavorites.swift
//  SNUYum
//
//  Created by SEONG YEOL YI on 2021/04/05.
//

import SwiftUI

struct ReorderFavorites: View {
    
    @State var ids: [RestaurantID] = []
    @EnvironmentObject var restaurantUpdater: RestaurantUpdater
    
    var body: some View {
        NavigationView {
            List {
                ForEach(ids) { id in
                    Text(Restaurant(id: id).name)
                }
                .onMove(perform: move)
            }
            .padding(.leading, -39)
            .padding(.top, 10)
            .navigationBarTitle(Text("즐겨찾기 수정"), displayMode: .inline)
            .environment(\.editMode, .constant(EditMode.active))
        }
        .onAppear {
            ids = restaurantUpdater.favoritesOrder
        }
        .onDisappear {
            withAnimation {
                restaurantUpdater.favoritesOrder = ids
            }
        }
    }
    
    func move(from source: IndexSet, to destination: Int) {
        ids.move(fromOffsets: source, toOffset: destination)
    }
}

struct ReorderFavorites_Previews: PreviewProvider {
    static var previews: some View {
        Text("")
            .sheet(isPresented: .constant(true)) {
                ReorderFavorites(ids: [.감골, .공대간이, .기숙사])
                    .environmentObject(RestaurantUpdater())
            }
    }
}
