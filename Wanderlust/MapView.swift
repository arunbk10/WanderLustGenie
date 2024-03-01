//
//  MapView.swift
//  Wanderlust
//
//  Created by Arun Kulkarni on 26/02/24.
//

import SwiftUI
import MapKit

struct MapView: View {
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    
    var body: some View {
        VStack {
            Map().cornerRadius(40)
            
            Spacer()
            Button("Go to Hotel View"){
                dismissWindow(id: "MapView")
                openWindow(id: "HotelListView")
            }
        }.padding(10)
            .glassBackgroundEffect()
    }
}

#Preview {
    MapView()
}
