//
//  MapView.swift
//  Wanderlust
//
//  Created by Arun Kulkarni on 26/02/24.
//

import SwiftUI
import MapKit

struct MapView: View {
    
    var body: some View {
        VStack {
            Map().cornerRadius(40)
            
            Spacer()
            Button("Go to Hotel View"){
                
            }
        }.padding(10)
            .glassBackgroundEffect()
    }
}

#Preview {
    MapView()
}
