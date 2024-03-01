//
//  WanderlustApp.swift
//  Wanderlust
//
//  Created by Arun Kulkarni on 22/02/24.
//

import SwiftUI

@main
struct WanderlustApp: App {
    
    @State private var viewModel = ChatViewModel()
    @State private var chatViewmodel = ViewModel()
    
    var body: some Scene {
        LaunchWindow()
        WindowGroup(id: "MapView"){
            MapView()
        }.windowStyle(.plain).defaultSize(width: 1, height: 0.8, depth: 0.0, in: .meters)
        
    }
}


