//
//  MapView.swift
//  IPScanner
//
//  Created by Timothy Sonner on 11/14/21.
//

import SwiftUI
import MapKit

struct MapView: View {
    
    @State private var region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: 0.0,
                longitude: 0.0
            ),
            span: MKCoordinateSpan(
                latitudeDelta: 10,
                longitudeDelta: 10
            )
        )
    let center: CLLocationCoordinate2D
    let span: MKCoordinateSpan
    var body: some View {
        Map(
                    coordinateRegion: $region,
                    interactionModes: MapInteractionModes.all,
                    showsUserLocation: true
                )
            .onAppear{
                self.region.center.longitude = center.longitude
                self.region.center.latitude = center.latitude
                self.region.span = span
            }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(center: CLLocationCoordinate2D(latitude: 25.7617,longitude: 80.1918), span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))
    }
}
