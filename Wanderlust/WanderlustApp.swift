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
    
    var body: some Scene {
        WindowGroup {
            ConversationView()           
        }.windowStyle(.plain)
            .defaultSize(width: 0.80, height: 0.75, depth: 1.0, in: .meters)
                .windowStyle(.plain)

        ImmersiveSpace(id: "Chatbot") {
            ImmersiveView().environment(viewModel)
        }
    }
}
