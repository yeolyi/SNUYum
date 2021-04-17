//
//  NaverMap.swift
//  SNUYum
//
//  Created by SEONG YEOL YI on 2021/04/05.
//

import SwiftUI
import NMapsMap
import CoreLocation

/// Map view element; shows cafe location using Naver map API.
struct NaverMap: UIViewRepresentable {
    
    let coord: NMGLatLng
    let zoomValue: Double = 15
    let isCompact: Bool
    private var locationManager = CLLocationManager()
    
    init(restaurant: Restaurant, isCompact: Bool = false) {
        self.isCompact = isCompact
        if let location = restaurant.location {
            coord = .init(lat: location.latitude, lng: location.longitude)
        } else {
            assertionFailure()
            coord = .init(lat: 37, lng: 132)
        }
    }
    
    func makeUIView(context: UIViewRepresentableContext<NaverMap>) -> NMFNaverMapView {
        let mapView: NMFNaverMapView = .init()
        
        if !isCompact {
            locationManager.requestWhenInUseAuthorization()
        }
        mapView.showScaleBar = false
        mapView.showLocationButton = !isCompact
        mapView.showZoomControls = !isCompact
        mapView.showCompass = !isCompact
        
        if isCompact {
            mapView.mapView.isZoomGestureEnabled = false
            mapView.mapView.isTiltGestureEnabled = false
            mapView.mapView.isRotateGestureEnabled = false
            mapView.mapView.isStopGestureEnabled = false
            mapView.mapView.allowsScrolling = false
        }
        
        let marker = NMFMarker()
        marker.position = coord
        marker.mapView = mapView.mapView
        
        let cameraPosition = NMFCameraPosition(coord, zoom: zoomValue)
        let cameraUpdate = NMFCameraUpdate(position: cameraPosition)
        mapView.mapView.moveCamera(cameraUpdate)
        
        return mapView
    }
    
    func updateUIView(_ uiView: NMFNaverMapView, context: UIViewRepresentableContext<NaverMap>) {
        
    }
}

struct NaverMap_Previews: PreviewProvider {
    static var previews: some View {
        NaverMap(restaurant: Restaurant(id: .기숙사), isCompact: false)
            .cornerRadius(10)
    }
}
