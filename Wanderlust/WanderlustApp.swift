//
//  WanderlustApp.swift
//  Wanderlust
//
//  Created by Arun Kulkarni on 22/02/24.
//

import SwiftUI

@main
struct WanderlustApp: App {
    @State private var hotelViewModel = HotelViewModel()
    @State private var hotelPlayerViewModel = HotelPlayerViewModel()
    @State private var viewModel = ChatViewModel()
    @State private var chatViewmodel = ViewModel()
    
    var body: some Scene {
        LaunchWindow()
        WindowGroup(id: "MapView"){
            MapView()
        }.windowStyle(.plain).defaultSize(width: 1.5, height: 1.5, depth: 1.0, in: .meters)
        WindowGroup(id: "HotelListView") {
            HotelListView(viewModel: hotelViewModel)
                .cornerRadius(16)
        }.windowStyle(.plain)
            .defaultSize(width: 1.6, height: 0.5, depth: 1, in: .meters)
        
        ImmersiveSpace(id: "ImmersiveSpace") {
            HotelistImmersiveView(viewModel: hotelViewModel)
        }.immersionStyle(selection: .constant(.full), in: .full)
        ImmersiveSpace(id: "HotelImmersiveSpace") {
            HotelImmersiveView(viewModel: hotelPlayerViewModel)
        }.immersionStyle(selection: .constant(.full), in: .full)
    }
}


